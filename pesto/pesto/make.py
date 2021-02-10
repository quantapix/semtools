
_simpleopts = re.compile(r'^[a-zA-Z]+(\s|$)')


def withoutdups(it):
    r = set()
    for i in it:
        if not i in r:
            r.add(i)
            yield i


def mtimeislater(deptime, targettime):
    """
    Is the mtime of the dependency later than the target?
    """

    if deptime is None:
        return True
    if targettime is None:
        return False
    # int(1000*x) because of http://bugs.python.org/issue10148
    return int(1000 * deptime) > int(1000 * targettime)


def getmtime(path):
    try:
        s = os.stat(path)
        return s.st_mtime
    except OSError:
        return None


def getindent(stack):
    return ''.ljust(len(stack) - 1)


def _if_else(c, t, f):
    if c:
        return t()
    return f()


class RemakeRuleContext(object):
    def __init__(self, target, makefile, rule, deps, tgtstack,
                 avoidremakeloop):
        self.target = target
        self.makefile = makefile
        self.rule = rule
        self.deps = deps
        self.tgtstack = tgtstack
        self.avoidremakeloop = avoidremakeloop

        self.running = False
        self.error = False
        self.depsremaining = len(deps) + 1
        self.remake = False

    def resolvedeps(self, serial, cb):
        self.resolvecb = cb
        self.didanything = False
        if serial:
            self._resolvedepsserial()
        else:
            self._resolvedepsparallel()

    def _weakdepfinishedserial(self, error, didanything):
        if error:
            self.remake = True
        self._depfinishedserial(False, didanything)

    def _depfinishedserial(self, error, didanything):
        assert error in (True, False)

        if didanything:
            self.didanything = True

        if error:
            self.error = True
            if not self.makefile.keepgoing:
                self.resolvecb(error=True, didanything=self.didanything)
                return

        if len(self.resolvelist):
            dep, weak = self.resolvelist.pop(0)
            self.makefile.context.defer(
                dep.make, self.makefile, self.tgtstack,
                weak and self._weakdepfinishedserial
                or self._depfinishedserial)
        else:
            self.resolvecb(error=self.error, didanything=self.didanything)

    def _resolvedepsserial(self):
        self.resolvelist = list(self.deps)
        self._depfinishedserial(False, False)

    def _startdepparallel(self, d):
        dep, weak = d
        if weak:
            depfinished = self._weakdepfinishedparallel
        else:
            depfinished = self._depfinishedparallel
        if self.makefile.error:
            depfinished(True, False)
        else:
            dep.make(self.makefile, self.tgtstack, depfinished)

    def _weakdepfinishedparallel(self, error, didanything):
        if error:
            self.remake = True
        self._depfinishedparallel(False, didanything)

    def _depfinishedparallel(self, error, didanything):
        assert error in (True, False)

        if error:
            print("<%s>: Found error" % self.target.target)
            self.error = True
        if didanything:
            self.didanything = True

        self.depsremaining -= 1
        if self.depsremaining == 0:
            self.resolvecb(error=self.error, didanything=self.didanything)

    def _resolvedepsparallel(self):
        self.depsremaining -= 1
        if self.depsremaining == 0:
            self.resolvecb(error=self.error, didanything=self.didanything)
            return

        self.didanything = False

        for d in self.deps:
            self.makefile.context.defer(self._startdepparallel, d)

    def _commandcb(self, error):
        assert error in (True, False)

        if error:
            self.runcb(error=True)
            return

        if len(self.commands):
            self.commands.pop(0)(self._commandcb)
        else:
            self.runcb(error=False)

    def runcommands(self, indent, cb):
        assert not self.running
        self.running = True

        self.runcb = cb

        if self.rule is None or not len(self.rule.commands):
            if self.target.mtime is None:
                self.target.beingremade()
            else:
                for d, weak in self.deps:
                    if mtimeislater(d.mtime, self.target.mtime):
                        if d.mtime is None:
                            self.target.beingremade()
                        else:
                            _log.info(
                                "%sNot remaking %s ubecause it would have no effect, even though %s is newer.",
                                indent, self.target.target, d.target)
                        break
            cb(error=False)
            return

        if self.rule.doublecolon:
            if len(self.deps) == 0:
                if self.avoidremakeloop:
                    _log.info(
                        "%sNot remaking %s using rule at %s because it would introduce an infinite loop.",
                        indent, self.target.target, self.rule.loc)
                    cb(error=False)
                    return

        remake = self.remake
        if remake:
            _log.info(
                "%sRemaking %s using rule at %s: weak dependency was not found.",
                indent, self.target.target, self.rule.loc)
        else:
            if self.target.mtime is None:
                remake = True
                _log.info(
                    "%sRemaking %s using rule at %s: target doesn't exist or is a forced target",
                    indent, self.target.target, self.rule.loc)

        if not remake:
            if self.rule.doublecolon:
                if len(self.deps) == 0:
                    _log.info(
                        "%sRemaking %s using rule at %s because there are no prerequisites listed for a double-colon rule.",
                        indent, self.target.target, self.rule.loc)
                    remake = True

        if not remake:
            for d, weak in self.deps:
                if mtimeislater(d.mtime, self.target.mtime):
                    _log.info(
                        "%sRemaking %s using rule at %s because %s is newer.",
                        indent, self.target.target, self.rule.loc, d.target)
                    remake = True
                    break

        if remake:
            self.target.beingremade()
            self.target.didanything = True
            try:
                self.commands = [
                    c
                    for c in self.rule.getcommands(self.target, self.makefile)
                ]
            except errors.MakeError as e:
                print(e)
                sys.stdout.flush()
                cb(error=True)
                return

            self._commandcb(False)
        else:
            cb(error=False)


MAKESTATE_NONE = 0
MAKESTATE_FINISHED = 1
MAKESTATE_WORKING = 2


class Target(object):
    """
    An actual (non-pattern) target.
    It holds target-specific vars and a list of rules. It may also point to a parent
    PatternTarget, if this target is being created by an implicit rule.
    The rules associated with this target may be Rule instances or, in the case of static pattern
    rules, PatternRule instances.
    """

    wasremade = False

    def __init__(self, target, makefile):
        assert isinstance(target, str_type)
        self.target = target
        self.vpathtarget = None
        self.rules = []
        self.vars = Vars(makefile.vars)
        self.explicit = False
        self._state = MAKESTATE_NONE

    def addrule(self, rule):
        assert isinstance(rule, (Rule, PatternRuleInstance))
        if len(self.rules) and rule.doublecolon != self.rules[0].doublecolon:
            raise errors.DataError(
                "Cannot have single- and double-colon rules for the same target. Prior rule location: %s"
                % self.rules[0].loc, rule.loc)

        if isinstance(rule, PatternRuleInstance):
            if len(rule.prule.targetpatterns) != 1:
                raise errors.DataError(
                    "Static pattern rules must only have one target pattern",
                    rule.prule.loc)
            if rule.prule.targetpatterns[0].match(self.target) is None:
                raise errors.DataError(
                    "Static pattern rule doesn't match target '%s'" %
                    self.target, rule.loc)

        self.rules.append(rule)

    def isdoublecolon(self):
        return self.rules[0].doublecolon

    def isphony(self, makefile):
        """Is this a phony target? We don't check for existence of phony tgts."""
        return makefile.gettarget('.PHONY').hasdependency(self.target)

    def hasdependency(self, t):
        for rule in self.rules:
            if t in rule.prerequisites:
                return True

        return False

    def resolveimplicitrule(self, makefile, tgtstack, rulestack):
        """
        Try to resolve an implicit rule to build this target.
        """
        # The steps in the GNU make manual Implicit-Rule-Search.html are very detailed. I hope they can be trusted.

        indent = getindent(tgtstack)

        _log.info("%sSearching for implicit rule to make '%s'", indent,
                  self.target)

        dir, s, file = util.strrpartition(self.target, '/')
        dir = dir + s

        candidates = []  # list of PatternRuleInstance

        hasmatch = util.any(
            (r.hasspecificmatch(file) for r in makefile.implicitrules))

        for r in makefile.implicitrules:
            if r in rulestack:
                _log.info("%s %s: Avoiding implicit rule recursion", indent,
                          r.loc)
                continue

            if not len(r.commands):
                continue

            for ri in r.matchesfor(dir, file, hasmatch):
                candidates.append(ri)

        newcandidates = []

        for r in candidates:
            depfailed = None
            for p in r.prerequisites:
                t = makefile.gettarget(p)
                t.resolvevpath(makefile)
                if not t.explicit and t.mtime is None:
                    depfailed = p
                    break

            if depfailed is not None:
                if r.doublecolon:
                    _log.info(
                        "%s Terminal rule at %s doesn't match: prerequisite '%s' not mentioned and doesn't exist.",
                        indent, r.loc, depfailed)
                else:
                    newcandidates.append(r)
                continue

            _log.info("%sFound implicit rule at %s for target '%s'", indent,
                      r.loc, self.target)
            self.rules.append(r)
            return

        # Try again, but this time with chaining and without terminal (double-colon) rules

        for r in newcandidates:
            newrulestack = rulestack + [r.prule]

            depfailed = None
            for p in r.prerequisites:
                t = makefile.gettarget(p)
                try:
                    t.resolvedeps(makefile, tgtstack, newrulestack, True)
                except errors.ResolutionError:
                    depfailed = p
                    break

            if depfailed is not None:
                _log.info(
                    "%s Rule at %s doesn't match: prerequisite '%s' could not be made.",
                    indent, r.loc, depfailed)
                continue

            _log.info("%sFound implicit rule at %s for target '%s'", indent,
                      r.loc, self.target)
            self.rules.append(r)
            return

        _log.info("%sCouldn't find implicit rule to remake '%s'", indent,
                  self.target)

    def ruleswithcommands(self):
        "The number of rules with commands"
        return reduce(lambda i, rule: i + (len(rule.commands) > 0), self.rules,
                      0)

    def resolvedeps(self, makefile, tgtstack, rulestack, recursive):
        """
        Resolve the actual path of this target, using vpath if necessary.
        Recursively resolve dependencies of this target. This means finding implicit
        rules which match the target, if appropriate.
        Figure out whether this target needs to be rebuild, and set self.outofdate
        appropriately.
        @param tgtstack is the current stack of dependencies being resolved. If
               this target is already in tgtstack, bail to prevent infinite
               recursion.
        @param rulestack is the current stack of implicit rules being used to resolve
               dependencies. A rule chain cannot use the same implicit rule twice.
        """
        assert makefile.parsingfinished

        if self.target in tgtstack:
            raise errors.ResolutionError("Recursive dependency: %s -> %s" %
                                         (" -> ".join(tgtstack), self.target))

        tgtstack = tgtstack + [self.target]

        indent = getindent(tgtstack)

        _log.info("%sConsidering target '%s'", indent, self.target)

        self.resolvevpath(makefile)

        # Sanity-check our rules. If we're single-colon, only one rule should have commands
        ruleswithcommands = self.ruleswithcommands()
        if len(self.rules) and not self.isdoublecolon():
            if ruleswithcommands > 1:
                # In GNU make this is a warning, not an error. I'm going to be stricter.
                # TODO: provide locations
                raise errors.DataError(
                    "Target '%s' has multiple rules with commands." %
                    self.target)

        if ruleswithcommands == 0:
            self.resolveimplicitrule(makefile, tgtstack, rulestack)

        # If a target is mentioned, but doesn't exist, has no commands and no
        # prerequisites, it is special and exists just to say that tgts which
        # depend on it are always out of date. This is like .FORCE but more
        # compatible with other makes.
        # Otherwise, we don't know how to make it.
        if not len(self.rules) and self.mtime is None and not util.any(
            (len(rule.prerequisites) > 0 for rule in self.rules)):
            raise errors.ResolutionError(
                "No rule to make target '%s' needed by %r" % (self.target,
                                                              tgtstack))

        if recursive:
            for r in self.rules:
                newrulestack = rulestack + [r]
                for d in r.prerequisites:
                    dt = makefile.gettarget(d)
                    if dt.explicit:
                        continue

                    dt.resolvedeps(makefile, tgtstack, newrulestack, True)

        for v in makefile.getpatternvarsfor(self.target):
            self.vars.merge(v)

    def resolvevpath(self, makefile):
        if self.vpathtarget is not None:
            return

        if self.isphony(makefile):
            self.vpathtarget = self.target
            self.mtime = None
            return

        if self.target.startswith('-l'):
            stem = self.target[2:]
            f, s, e = makefile.vars.get('.LIBPATTERNS')
            if e is not None:
                libpatterns = [
                    Pattern(stripdotslash(s))
                    for s in e.resolvesplit(makefile, makefile.vars)
                ]
                if len(libpatterns):
                    searchdirs = ['']
                    searchdirs.extend(makefile.getvpath(self.target))

                    for lp in libpatterns:
                        if not lp.ispattern():
                            raise errors.DataError(
                                '.LIBPATTERNS contains a non-pattern')

                        libname = lp.resolve('', stem)

                        for dir in searchdirs:
                            libpath = util.normaljoin(dir, libname).replace(
                                '\\', '/')
                            fspath = util.normaljoin(makefile.workdir, libpath)
                            mtime = getmtime(fspath)
                            if mtime is not None:
                                self.vpathtarget = libpath
                                self.mtime = mtime
                                return

                    self.vpathtarget = self.target
                    self.mtime = None
                    return

        search = [self.target]
        if not os.path.isabs(self.target):
            search += [
                util.normaljoin(dir, self.target).replace('\\', '/')
                for dir in makefile.getvpath(self.target)
            ]

        targetandtime = self.searchinlocs(makefile, search)
        if targetandtime is not None:
            (self.vpathtarget, self.mtime) = targetandtime
            return

        self.vpathtarget = self.target
        self.mtime = None

    def searchinlocs(self, makefile, locs):
        """
        Look in the given locations relative to the makefile working directory
        for a file. Return a pair of the target and the mtime if found, None
        if not.
        """
        for t in locs:
            fspath = util.normaljoin(makefile.workdir, t).replace('\\', '/')
            mtime = getmtime(fspath)
            #            _log.info("Searching %s ... checking %s ... mtime %r" % (t, fspath, mtime))
            if mtime is not None:
                return (t, mtime)

        return None

    def beingremade(self):
        """
        When we remake ourself, we have to drop any vpath prefixes.
        """
        self.vpathtarget = self.target
        self.wasremade = True

    def notifydone(self, makefile):
        assert self._state == MAKESTATE_WORKING, "State was %s" % self._state
        # If we were remade then resolve mtime again
        if self.wasremade:
            targetandtime = self.searchinlocs(makefile, [self.target])
            if targetandtime is not None:
                (_, self.mtime) = targetandtime
            else:
                self.mtime = None

        self._state = MAKESTATE_FINISHED
        for cb in self._callbacks:
            makefile.context.defer(
                cb, error=self.error, didanything=self.didanything)
        del self._callbacks

    def make(self,
             makefile,
             tgtstack,
             cb,
             avoidremakeloop=False,
             printerror=True):
        """
        If we are out of date, asynchronously make ourself. This is a multi-stage process, mostly handled
        by the helper objects RemakeTgtserially, RemakeTargetParallel,
        RemakeRuleContext. These helper objects should keep us from developing
        any cyclical dependencies.
        * resolve dependencies (synchronous)
        * gather a list of rules to execute and related dependencies (synchronous)
        * for each rule (in parallel)
        ** remake dependencies (asynchronous)
        ** build list of commands to execute (synchronous)
        ** execute each command (asynchronous)
        * asynchronously notify when all rules are complete
        @param cb A callback function to notify when remaking is finished. It is called
               thusly: callback(error=True/False, didanything=True/False)
               If there is no asynchronous activity to perform, the callback may be called directly.
        """

        serial = makefile.context.jcount == 1

        if self._state == MAKESTATE_FINISHED:
            cb(error=self.error, didanything=self.didanything)
            return

        if self._state == MAKESTATE_WORKING:
            assert not serial
            self._callbacks.append(cb)
            return

        assert self._state == MAKESTATE_NONE

        self._state = MAKESTATE_WORKING
        self._callbacks = [cb]
        self.error = False
        self.didanything = False

        indent = getindent(tgtstack)

        try:
            self.resolvedeps(makefile, tgtstack, [], False)
        except errors.MakeError as e:
            if printerror:
                print(e)
            self.error = True
            self.notifydone(makefile)
            return

        assert self.vpathtarget is not None, "Target was never resolved!"
        if not len(self.rules):
            self.notifydone(makefile)
            return

        if self.isdoublecolon():
            rulelist = [
                RemakeRuleContext(self, makefile, r,
                                  [(makefile.gettarget(p), False)
                                   for p in r.prerequisites], tgtstack,
                                  avoidremakeloop) for r in self.rules
            ]
        else:
            alldeps = []

            commandrule = None
            for r in self.rules:
                rdeps = [(makefile.gettarget(p), r.weakdeps)
                         for p in r.prerequisites]
                if len(r.commands):
                    assert commandrule is None
                    commandrule = r
                    # The dependencies of the command rule are resolved before other dependencies,
                    # no matter the ordering of the other no-command rules
                    alldeps[0:0] = rdeps
                else:
                    alldeps.extend(rdeps)

            rulelist = [
                RemakeRuleContext(self, makefile, commandrule, alldeps,
                                  tgtstack, avoidremakeloop)
            ]

        tgtstack = tgtstack + [self.target]

        if serial:
            RemakeTgtserially(self, makefile, indent, rulelist)
        else:
            RemakeTargetParallel(self, makefile, indent, rulelist)


def dirpart(p):
    d, s, f = util.strrpartition(p, '/')
    if d == '':
        return '.'

    return d


def filepart(p):
    d, s, f = util.strrpartition(p, '/')
    return f


def setautomatic(v, name, plist):
    v.set(name, Vars.FLAVOR_SIMPLE, Vars.SOURCE_AUTOMATIC, ' '.join(plist))
    v.set(name + 'D', Vars.FLAVOR_SIMPLE, Vars.SOURCE_AUTOMATIC, ' '.join(
        (dirpart(p) for p in plist)))
    v.set(name + 'F', Vars.FLAVOR_SIMPLE, Vars.SOURCE_AUTOMATIC, ' '.join(
        (filepart(p) for p in plist)))


def setautomaticvars(v, makefile, target, prerequisites):
    prtgts = [makefile.gettarget(p) for p in prerequisites]
    prall = [pt.vpathtarget for pt in prtgts]
    proutofdate = [
        pt.vpathtarget for pt in withoutdups(prtgts)
        if target.mtime is None or mtimeislater(pt.mtime, target.mtime)
    ]

    setautomatic(v, '@', [target.vpathtarget])
    if len(prall):
        setautomatic(v, '<', [prall[0]])

    setautomatic(v, '?', proutofdate)
    setautomatic(v, '^', list(withoutdups(prall)))
    setautomatic(v, '+', prall)


def splitcommand(command):
    """
    Using the esoteric rules, split command lines by unescaped newlines.
    """
    start = 0
    i = 0
    while i < len(command):
        c = command[i]
        if c == '\\':
            i += 1
        elif c == '\n':
            yield command[start:i]
            i += 1
            start = i
            continue

        i += 1

    if i > start:
        yield command[start:i]


def findmodifiers(command):
    """
    Find any of +-@% prefixed on the command.
    @returns (command, isHidden, isRecursive, ignoreErrors, isNative)
    """

    isHidden = False
    isRecursive = False
    ignoreErrors = False
    isNative = False

    realcommand = command.lstrip(' \t\n@+-%')
    modset = set(command[:-len(realcommand)])
    return realcommand, '@' in modset, '+' in modset, '-' in modset, '%' in modset


class _CommandWrapper(object):
    def __init__(self, cline, ignoreErrors, loc, context, **kwargs):
        self.ignoreErrors = ignoreErrors
        self.loc = loc
        self.cline = cline
        self.kwargs = kwargs
        self.context = context

    def _cb(self, res):
        if res != 0 and not self.ignoreErrors:
            print("%s: command '%s' failed, return code %i" %
                  (self.loc, self.cline, res))
            self.usercb(error=True)
        else:
            self.usercb(error=False)

    def __call__(self, cb):
        self.usercb = cb
        process.call(
            self.cline,
            loc=self.loc,
            cb=self._cb,
            context=self.context,
            **self.kwargs)


class _NativeWrapper(_CommandWrapper):
    def __init__(self, cline, ignoreErrors, loc, context, pycommandpath,
                 **kwargs):
        _CommandWrapper.__init__(self, cline, ignoreErrors, loc, context,
                                 **kwargs)
        if pycommandpath:
            self.pycommandpath = re.split('[%s\s]+' % os.pathsep,
                                          pycommandpath)
        else:
            self.pycommandpath = None

    def __call__(self, cb):
        # get the module and method to call
        parts, badchar = process.clinetoargv(self.cline, self.kwargs['cwd'])
        if parts is None:
            raise errors.DataError(
                "native command '%s': shell metacharacter '%s' in command line"
                % (self.cline, badchar), self.loc)
        if len(parts) < 2:
            raise errors.DataError(
                "native command '%s': no method name specified" % self.cline,
                self.loc)
        module = parts[0]
        method = parts[1]
        cline_list = parts[2:]
        self.usercb = cb
        process.call_native(
            module,
            method,
            cline_list,
            loc=self.loc,
            cb=self._cb,
            context=self.context,
            pycommandpath=self.pycommandpath,
            **self.kwargs)


def getcommandsforrule(rule, target, makefile, prerequisites, stem):
    v = Vars(parent=target.vars)
    setautomaticvars(v, makefile, target, prerequisites)
    if stem is not None:
        setautomatic(v, '*', [stem])

    env = makefile.getsubenvironment(v)

    for c in rule.commands:
        cstring = c.resolvestr(makefile, v)
        for cline in splitcommand(cstring):
            cline, isHidden, isRecursive, ignoreErrors, isNative = findmodifiers(
                cline)
            if (isHidden or makefile.silent) and not makefile.justprint:
                echo = None
            else:
                echo = "%s$ %s" % (c.loc, cline)
            if not isNative:
                yield _CommandWrapper(
                    cline,
                    ignoreErrors=ignoreErrors,
                    env=env,
                    cwd=makefile.workdir,
                    loc=c.loc,
                    context=makefile.context,
                    echo=echo,
                    justprint=makefile.justprint)
            else:
                f, s, e = v.get("PYCOMMANDPATH", True)
                if e:
                    e = e.resolvestr(makefile, v, ["PYCOMMANDPATH"])
                yield _NativeWrapper(
                    cline,
                    ignoreErrors=ignoreErrors,
                    env=env,
                    cwd=makefile.workdir,
                    loc=c.loc,
                    context=makefile.context,
                    echo=echo,
                    justprint=makefile.justprint,
                    pycommandpath=e)


class Rule(object):
    """
    A rule contains a list of prerequisites and a list of commands. It may also
    contain rule-specific vars. This rule may be associated with multiple tgts.
    """

    def __init__(self, prereqs, doublecolon, loc, weakdeps):
        self.prerequisites = prereqs
        self.doublecolon = doublecolon
        self.commands = []
        self.loc = loc
        self.weakdeps = weakdeps

    def addcommand(self, c):
        assert isinstance(c, (Expansion, StringExpansion))
        self.commands.append(c)

    def getcommands(self, target, makefile):
        assert isinstance(target, Target)
        # Prerequisites are merged if the target contains multiple rules and is
        # not a terminal (double colon) rule. See
        # https://www.gnu.org/software/make/manual/make.html#Multiple-Tgts.
        prereqs = []
        prereqs.extend(self.prerequisites)

        if not self.doublecolon:
            for rule in target.rules:
                # The current rule comes first, which is already in prereqs so
                # we don't need to add it again.
                if rule != self:
                    prereqs.extend(rule.prerequisites)

        return getcommandsforrule(self, target, makefile, prereqs, stem=None)
        # TODO: $* in non-pattern rules?


class PatternRuleInstance(object):
    weakdeps = False
    """
    A pattern rule instantiated for a particular target. It has the same API as Rule, but
    different internals, forwarding most information on to the PatternRule.
    """

    def __init__(self, prule, dir, stem, ismatchany):
        assert isinstance(prule, PatternRule)

        self.dir = dir
        self.stem = stem
        self.prule = prule
        self.prerequisites = prule.prerequisitesforstem(dir, stem)
        self.doublecolon = prule.doublecolon
        self.loc = prule.loc
        self.ismatchany = ismatchany
        self.commands = prule.commands

    def getcommands(self, target, makefile):
        assert isinstance(target, Target)
        return getcommandsforrule(
            self,
            target,
            makefile,
            self.prerequisites,
            stem=self.dir + self.stem)

    def __str__(self):
        return "Pattern rule at %s with stem '%s', matchany: %s doublecolon: %s" % (
            self.loc, self.dir + self.stem, self.ismatchany, self.doublecolon)


class PatternRule(object):
    """
    An implicit rule or static pattern rule containing target patterns, prerequisite patterns,
    and a list of commands.
    """

    def __init__(self, targetpatterns, prerequisites, doublecolon, loc):
        self.targetpatterns = targetpatterns
        self.prerequisites = prerequisites
        self.doublecolon = doublecolon
        self.loc = loc
        self.commands = []

    def addcommand(self, c):
        assert isinstance(c, (Expansion, StringExpansion))
        self.commands.append(c)

    def ismatchany(self):
        return util.any((t.ismatchany() for t in self.targetpatterns))

    def hasspecificmatch(self, file):
        for p in self.targetpatterns:
            if not p.ismatchany() and p.match(file) is not None:
                return True

        return False

    def matchesfor(self, dir, file, skipsinglecolonmatchany):
        """
        Determine all the target patterns of this rule that might match target t.
        @yields a PatternRuleInstance for each.
        """

        for p in self.targetpatterns:
            matchany = p.ismatchany()
            if matchany:
                if skipsinglecolonmatchany and not self.doublecolon:
                    continue

                yield PatternRuleInstance(self, dir, file, True)
            else:
                stem = p.match(dir + file)
                if stem is not None:
                    yield PatternRuleInstance(self, '', stem, False)
                else:
                    stem = p.match(file)
                    if stem is not None:
                        yield PatternRuleInstance(self, dir, stem, False)

    def prerequisitesforstem(self, dir, stem):
        return [p.resolve(dir, stem) for p in self.prerequisites]


class _RemakeContext(object):
    def __init__(self, makefile, cb):
        self.makefile = makefile
        self.included = [(makefile.gettarget(f), required)
                         for f, required in makefile.included]
        self.toremake = list(self.included)
        self.cb = cb

        self.remakecb(error=False, didanything=False)

    def remakecb(self, error, didanything):
        assert error in (True, False)

        if error:
            if self.required:
                self.cb(
                    remade=False,
                    error=errors.MakeError(
                        'Error remaking required makefiles'))
                return
            else:
                print('Error remaking makefiles (ignored)')

        if len(self.toremake):
            target, self.required = self.toremake.pop(0)
            target.make(
                self.makefile, [],
                avoidremakeloop=True,
                cb=self.remakecb,
                printerror=False)
        else:
            for t, required in self.included:
                if t.wasremade:
                    _log.info("Included file %s was remade, restarting make",
                              t.target)
                    self.cb(remade=True)
                    return
                elif required and t.mtime is None:
                    self.cb(
                        remade=False,
                        error=errors.DataError(
                            "No rule to remake missing include file %s" %
                            t.target))
                    return

            self.cb(remade=False)


class Makefile:
    def __init__(
            self,
            workdir=None,
            env=None,
            restarts=0,
            make=None,
            makeflags='',
            makeoverrides='',
            level=0,
            context=None,
            tgts=(),
    ):
        self.defaulttarget = None

        if env is None:
            env = os.environ
        self.env = env

        self.vars = Vars()
        self.vars.readfromenvironment(env)

        self.context = context
        self.exportedvars = {}
        self._tgts = {}
        self._patternvars = []  # of (pattern, vars)
        self.implicitrules = []
        self.parsingfinished = False

        self._patternvpaths = []  # of (pattern, [dir, ...])

        if workdir is None:
            workdir = os.getcwd()
        workdir = os.path.realpath(workdir)
        self.workdir = workdir
        self.vars.set('CURDIR', Vars.FLAVOR_SIMPLE, Vars.SOURCE_AUTOMATIC,
                      workdir.replace('\\', '/'))

        # the list of included makefiles, whether or not they existed
        self.included = []

        self.vars.set('MAKE_RESTARTS', Vars.FLAVOR_SIMPLE,
                      Vars.SOURCE_AUTOMATIC, restarts > 0 and str(restarts)
                      or '')

        self.vars.set('.PYMAKE', Vars.FLAVOR_SIMPLE, Vars.SOURCE_MAKEFILE, "1")
        if make is not None:
            self.vars.set('MAKE', Vars.FLAVOR_SIMPLE, Vars.SOURCE_MAKEFILE,
                          make)

        if makeoverrides != '':
            self.vars.set('-*-command-vars-*-', Vars.FLAVOR_SIMPLE,
                          Vars.SOURCE_AUTOMATIC, makeoverrides)
            makeflags += ' -- $(MAKEOVERRIDES)'

        self.vars.set('MAKEOVERRIDES', Vars.FLAVOR_RECURSIVE,
                      Vars.SOURCE_ENVIRONMENT, '${-*-command-vars-*-}')

        self.vars.set('MAKEFLAGS', Vars.FLAVOR_RECURSIVE, Vars.SOURCE_MAKEFILE,
                      makeflags)
        self.exportedvars['MAKEFLAGS'] = True

        self.level = level
        self.vars.set('LEVEL', Vars.FLAVOR_SIMPLE, Vars.SOURCE_MAKEFILE,
                      str(level))

        self.vars.set('MAKECMDGOALS', Vars.FLAVOR_SIMPLE,
                      Vars.SOURCE_AUTOMATIC, ' '.join(tgts))

        for vname, val in implicit.vars.items():
            self.vars.set(vname, Vars.FLAVOR_SIMPLE, Vars.SOURCE_IMPLICIT, val)

    def foundtarget(self, t):
        """
        Inform the makefile of a target which is a candidate for being the default target,
        if there isn't already a default target.
        """
        flavor, source, value = self.vars.get('.DEFAULT_GOAL')
        if self.defaulttarget is None and t != '.PHONY' and value is None:
            self.defaulttarget = t
            self.vars.set('.DEFAULT_GOAL', Vars.FLAVOR_SIMPLE,
                          Vars.SOURCE_AUTOMATIC, t)

    def getpatternvars(self, pattern):
        assert isinstance(pattern, Pattern)

        for p, v in self._patternvars:
            if p == pattern:
                return v

        v = Vars()
        self._patternvars.append((pattern, v))
        return v

    def getpatternvarsfor(self, target):
        for p, v in self._patternvars:
            if p.match(target):
                yield v

    def hastarget(self, target):
        return target in self._tgts

    _globcheck = re.compile('[[*?]')

    def gettarget(self, target):
        assert isinstance(target, str_type)

        target = target.rstrip('/')

        assert target != '', "empty target?"

        assert not self._globcheck.match(target)

        t = self._tgts.get(target, None)
        if t is None:
            t = Target(target, self)
            self._tgts[target] = t
        return t

    def appendimplicitrule(self, rule):
        assert isinstance(rule, PatternRule)
        self.implicitrules.append(rule)

    def finishparsing(self):
        self.parsingfinished = True

        flavor, source, value = self.vars.get('GPATH')
        if value is not None and value.resolvestr(self, self.vars,
                                                  ['GPATH']).strip() != '':
            raise errors.DataError(
                'GPATH was set: pymake does not support GPATH semantics')

        flavor, source, value = self.vars.get('VPATH')
        if value is None:
            self._vpath = []
        else:
            self._vpath = [
                e
                for e in re.split('[%s\s]+' % os.pathsep,
                                  value.resolvestr(self, self.vars, ['VPATH']))
                if e != ''
            ]

        # Must materialize target values because
        # gettarget() modifies self._tgts.
        tgts = list(self._tgts.values())
        for t in tgts:
            t.explicit = True
            for r in t.rules:
                for p in r.prerequisites:
                    self.gettarget(p).explicit = True

        np = self.gettarget('.NOTPARALLEL')
        if len(np.rules):
            self.context = process.getcontext(1)

        flavor, source, value = self.vars.get('.DEFAULT_GOAL')
        if value is not None:
            self.defaulttarget = value.resolvestr(self, self.vars,
                                                  ['.DEFAULT_GOAL']).strip()

        self.error = False

    def include(self, path, required=True, weak=False, loc=None):
        if self._globcheck.search(path):
            paths = globrelative.glob(self.workdir, path)
        else:
            paths = [path]
        for path in paths:
            self.included.append((path, required))
            fspath = util.normaljoin(self.workdir, path)
            if os.path.exists(fspath):
                if weak:
                    stmts = parser.parsedepfile(fspath)
                else:
                    stmts = parser.parsefile(fspath)
                self.vars.append('MAKEFILE_LIST', Vars.SOURCE_AUTOMATIC, path,
                                 None, self)
                stmts.execute(self, weak=weak)
                self.gettarget(path).explicit = True

    def addvpath(self, pattern, dirs):
        """
        Add a directory to the vpath search for the given pattern.
        """
        self._patternvpaths.append((pattern, dirs))

    def clearvpath(self, pattern):
        """
        Clear vpaths for the given pattern.
        """
        self._patternvpaths = [(p, dirs) for p, dirs in self._patternvpaths
                               if not p.match(pattern)]

    def clearallvpaths(self):
        self._patternvpaths = []

    def getvpath(self, target):
        vp = list(self._vpath)
        for p, dirs in self._patternvpaths:
            if p.match(target):
                vp.extend(dirs)

        return withoutdups(vp)

    def remakemakefiles(self, cb):
        mlist = []
        for f, required in self.included:
            t = self.gettarget(f)
            t.explicit = True
            t.resolvevpath(self)
            oldmtime = t.mtime

            mlist.append((t, oldmtime))

        _RemakeContext(self, cb)

    def getsubenvironment(self, vars):
        env = dict(self.env)
        for vname, v in self.exportedvars.items():
            if v:
                flavor, source, val = vars.get(vname)
                if val is None:
                    strval = ''
                else:
                    strval = val.resolvestr(self, vars, [vname])
                env[vname] = strval
            else:
                env.pop(vname, None)

        makeflags = ''

        env['LEVEL'] = str(self.level + 1)
        return env


class _MakeContext:
    def __init__(self, makeflags, level, workdir, context, env, tgts, options,
                 ostmts, overrides, cb):
        self.makeflags = makeflags
        self.level = level

        self.workdir = workdir
        self.context = context
        self.env = env
        self.tgts = tgts
        self.options = options
        self.ostmts = ostmts
        self.overrides = overrides
        self.cb = cb

        self.restarts = 0

        self.remakecb(True)

    def remakecb(self, remade, error=None):
        if error is not None:
            print(error)
            self.context.defer(self.cb, 2)
            return

        if remade:
            if self.restarts > 0:
                _log.info("make.py[%i]: Restarting makefile parsing",
                          self.level)

            self.makefile = data.Makefile(
                restarts=self.restarts,
                make='%s %s' % (sys.executable.replace('\\', '/'),
                                makepypath.replace('\\', '/')),
                makeflags=self.makeflags,
                makeoverrides=self.overrides,
                workdir=self.workdir,
                context=self.context,
                env=self.env,
                level=self.level,
                tgts=self.tgts,
                keepgoing=self.options.keepgoing,
                silent=self.options.silent,
                justprint=self.options.justprint)

            self.restarts += 1

            try:
                self.ostmts.execute(self.makefile)
                for f in self.options.makefiles:
                    self.makefile.include(f)
                self.makefile.finishparsing()
                self.makefile.remakemakefiles(self.remakecb)
            except errors.MakeError as e:
                print(e)
                self.context.defer(self.cb, 2)

            return

        if len(self.tgts) == 0:
            if self.makefile.defaulttarget is None:
                print("No target specified and no default target found.")
                self.context.defer(self.cb, 2)
                return

            _log.info("Making default target %s", self.makefile.defaulttarget)
            self.realtgts = [self.makefile.defaulttarget]
            self.tstack = ['<default-target>']
        else:
            self.realtgts = self.tgts
            self.tstack = ['<command-line>']

        self.makefile.gettarget(self.realtgts.pop(0)).make(
            self.makefile, self.tstack, cb=self.makecb)

    def makecb(self, error, didanything):
        assert error in (True, False)

        if error:
            self.context.defer(self.cb, 2)
            return

        if not len(self.realtgts):
            if self.options.printdir:
                print("make.py[%i]: Leaving directory '%s'" % (self.level,
                                                               self.workdir))
            sys.stdout.flush()

            self.context.defer(self.cb, 0)
        else:
            self.makefile.gettarget(self.realtgts.pop(0)).make(
                self.makefile, self.tstack, self.makecb)


if __name__ == '__main__':
    import os
    p = os.environ.get('PESTO_ROOT')
    from argparse import ArgumentParser
    args = ArgumentParser()
    args.add_argument('-p', '--root', help='Path to root', default=p)
    args.add_argument('-n', '--name', help='Name of repo')
    args.add_argument('-b', '--branch', help='Branch')
    st = 'store_true'
    args.add_argument('-r', '--repatch', action=st, help='Repatch branch')
    args.add_argument('-d', '--rediff', action=st, help='Rediff branch')
    args.add_argument('-c', '--commit', action=st, help='Commit diffs')
    args.add_argument('-u', '--pull', action=st, help='Pull upstream')
    args = args.parse_args()
    r = Repo(args.name, args.branch, root=args.root)
    if args.repatch:
        r.repatch()
    elif args.rediff:
        r.repatch(update=True)
    elif args.commit:
        r.commit()
    elif args.pull:
        r.pull()
