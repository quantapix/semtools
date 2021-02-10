#!/usr/bin/python

import re
import os

import functions


class Position:

    _tabwidth = 4

    def __init__(self, path, line, char):
        self.path = path
        self.line = line
        self.char = char

    def offset(self, s, start, end):
        if start == end:
            return self
        skip = s.count('\n', start, end)
        if skip:
            last = s.rfind('\n', start, end)
            assert last != -1
            start = last + 1
            c = 0
        else:
            c = self.char
        while True:
            j = s.find('\t', start, end)
            if j == -1:
                c += end - start
                break
            c += j - start
            c += self._tabwidth
            c -= c % self._tabwidth
            start = j + 1
        return Position(self.path, self.line + skip, c)

    def __str__(self):
        return "{}:{}:{}".format(self.path, self.line, self.char)


class BaseExpansion:
    def functions(self, descend=False):
        for f in ():
            yield f

    def variable_refs(self, descend=False):
        for f in self.functions(descend=descend):
            if isinstance(f, functions.VariableRef):
                yield f

    @property
    def is_filesystem_dep(self):
        for f in self.functions(descend=True):
            if f.is_filesystem_dependent:
                return True
        return False

    @property
    def is_shell_dep(self):
        for f in self.functions(descend=True):
            if isinstance(f, functions.ShellFunction):
                return True
        return False


class StringExpansion(BaseExpansion):

    simple = True

    def __init__(self, s, pos):
        self.s = s
        self.pos = pos

    def lstrip(self):
        self.s = self.s.lstrip()

    def rstrip(self):
        self.s = self.s.rstrip()

    def isempty(self):
        return self.s == ''

    def resolve(self, i, j, fd, k=None):
        fd.write(self.s)

    def resolvestr(self, i, j, k=None):
        return self.s

    def resolvesplit(self, i, j, k=None):
        return self.s.split()

    def clone(self):
        e = Expansion(self.pos)
        e.appendstr(self.s)
        return e

    @property
    def is_static_string(self):
        return True

    def __len__(self):
        return 1

    def __getitem__(self, i):
        assert i == 0
        return self.s, False

    def __repr__(self):
        return "Exp<%s>(%r)" % (self.pos, self.s)

    def __eq__(self, other):
        return self.s == other

    def to_src(self, escape_variables=False, escape_comments=False):
        s = self.s
        if escape_comments:
            s = s.replace('#', '\\#')
        if escape_variables:
            return s.replace('$', '$$')
        return s


class Expansion(BaseExpansion, list):

    simple = False

    def __init__(self, pos=None):
        # A list of (element, isfunc) tuples
        # element is either a string or a function
        self.pos = pos

    @staticmethod
    def from_string(s, path):
        return StringExpansion(s, Position(path, 1, 0))

    def clone(self):
        e = Expansion()
        e.extend(self)
        return e

    def appendstr(self, s):
        assert isinstance(s, str)
        if s:
            self.append((s, False))

    def appendfunc(self, func):
        assert isinstance(func, functions.Function)
        self.append((func, True))

    def concat(self, o):
        if o.simple:
            self.appendstr(o.s)
        else:
            self.extend(o)

    def isempty(self):
        return (not len(self)) or self[0] == ('', False)

    def lstrip(self):
        while True:
            i, isfunc = self[0]
            if isfunc:
                return
            i = i.lstrip()
            if i:
                self[0] = i, False
                return
            del self[0]

    def rstrip(self):
        while True:
            i, isfunc = self[-1]
            if isfunc:
                return
            i = i.rstrip()
            if i:
                self[-1] = i, False
                return
            del self[-1]

    def finish(self):
        # Merge any adjacent literal strings:
        strings = []
        elements = []
        for (e, isfunc) in self:
            if isfunc:
                if strings:
                    s = ''.join(strings)
                    if s:
                        elements.append((s, False))
                    strings = []
                elements.append((e, True))
            else:
                strings.append(e)
        if not elements:
            # This can only happen if there were no function elements.
            return StringExpansion(''.join(strings), self.pos)
        if strings:
            s = ''.join(strings)
            if s:
                elements.append((s, False))
        if len(elements) < len(self):
            self[:] = elements
        return self

    def resolve(self, makefile, variables, fd, setting=[]):
        """
        Resolve this variable into a value, by interpolating the value
        of other variables.
        @param setting (Variable instance) the variable currently
               being set, if any. Setting variables must avoid self-referential
               loops.
        """
        assert isinstance(makefile, Makefile)
        assert isinstance(variables, Variables)
        assert isinstance(setting, list)

        for e, isfunc in self:
            if isfunc:
                e.resolve(makefile, variables, fd, setting)
            else:
                assert isinstance(e, str)
                fd.write(e)

    def resolvestr(self, makefile, variables, setting=[]):
        pass
        # fd = StringIO()
        # self.resolve(makefile, variables, fd, setting)
        # return fd.getvalue()

    def resolvesplit(self, makefile, variables, setting=[]):
        return self.resolvestr(makefile, variables, setting).split()

    @property
    def is_static_string(self):
        for e, is_func in self:
            if is_func:
                return False
        return True

    def functions(self, descend=False):
        for e, is_func in self:
            if is_func:
                yield e
            if descend:
                for exp in e.expansions(descend=True):
                    for f in exp.functions(descend=True):
                        yield f

    def __repr__(self):
        return "<Expansion with elements: %r>" % ([e for e, isfunc in self], )

    def to_src(self, escape_variables=False, escape_comments=False):
        parts = []
        for e, is_func in self:
            if is_func:
                parts.append(e.to_src())
                continue

            if escape_variables:
                parts.append(e.replace('$', '$$'))
                continue

            parts.append(e)

        return ''.join(parts)

    def __eq__(self, other):
        if not isinstance(other, (Expansion, StringExpansion)):
            return False

        # Expansions are equivalent if adjacent string literals normalize to
        # the same value. So, we must normalize before any comparisons are
        # made.
        a = self.clone().finish()

        if isinstance(other, StringExpansion):
            if isinstance(a, StringExpansion):
                return a == other

            # A normalized Expansion != StringExpansion.
            return False

        b = other.clone().finish()

        # b could be a StringExpansion now.
        if isinstance(b, StringExpansion):
            if isinstance(a, StringExpansion):
                return a == b

            # Our normalized Expansion != normalized StringExpansion.
            return False

        if len(a) != len(b):
            return False

        for i in range(len(self)):
            e1, is_func1 = a[i]
            e2, is_func2 = b[i]

            if is_func1 != is_func2:
                return False

            if type(e1) != type(e2):
                return False

            if e1 != e2:
                return False

        return True


class Variables:

    RECURS = 0
    SIMPLE = 1
    APPEND = 2

    OVERRIDE = 0
    CMDLINE = 1
    MAKEFILE = 2
    ENVIRON = 3
    AUTO = 4
    IMPLICIT = 5

    def __init__(self, parent=None):
        self.parent = parent
        self.map = {}  # vname -> kind, src, valstr, valexp

    def from_env(self, env):
        for n, v in env.items():
            self.set(n, self.RECURS, self.ENVIRON, v)

    def get(self, name, expand=True):
        d = (None, None, None, None)
        kind, src, val, vexp = self.map.get(name, d)
        path = "Expansion of variable '{}'".format(name)
        if kind is not None:
            if expand and kind != self.SIMPLE and vexp is None:
                r = Row.from_string(val, path)
                vexp, t, o = r.parse(0, (), r.var_gen)
                self.map[name] = kind, src, val, vexp
            if kind == self.APPEND:
                if self.parent:
                    pkind, psrc, pval = self.parent.get(name, expand)
                else:
                    pkind, psrc, pval = None, None, None
                if pval is None:
                    kind = self.RECURS
                else:
                    if src > psrc:
                        return pkind, psrc, pval
                    if not expand:
                        return pkind, psrc, pval + ' ' + val
                    pval = pval.clone()
                    pval.appendstr(' ')
                    pval.concat(vexp)
                    return pkind, psrc, pval
            if not expand:
                return kind, src, val
            if kind == self.RECURS:
                val = vexp
            else:
                val = Expansion.from_string(val, path)
            return kind, src, val
        if self.parent is None:
            return (None, None, None)
        return self.parent.get(name, expand)

    def set(self, name, kind, src, val, force=False):
        pkind, psrc, pval = self.get(name)
        if psrc is not None and src > psrc and not force:
            return
        self.map[name] = kind, src, val, None

    def append(self, name, src, val, variables, makefile):
        if name not in self.map:
            self.map[name] = self.APPEND, src, val, None
            return
        pkind, psrc, pval, vexp = self.map[name]
        if src > psrc:
            return
        if pkind == self.SIMPLE:
            path = "Expansion of variable '{}'".format(name)
            r = Row.from_string(val, path)
            vexp, t, o = r.parse(0, (), r.var_gen)
            val = vexp.resolvestr(makefile, variables, [name])
            self.map[name] = pkind, psrc, pval + ' ' + val, None
            return
        nval = pval + ' ' + val
        self.map[name] = pkind, psrc, nval, None

    def merge(self, other):
        assert isinstance(other, Variables)
        for n, kind, src, val in other:
            self.set(n, kind, src, val)

    def __iter__(self):
        for n, (kind, src, val, valexp) in self.map.items():
            yield n, kind, src, val

    def __contains__(self, name):
        return name in self.map


class Pattern(object):
    """
    A pattern is a string, possibly with a % substitution character. From the GNU make manual:
    '%' characters in pattern rules can be quoted with precending backslashes ('\'). Backslashes that
    would otherwise quote '%' charcters can be quoted with more backslashes. Backslashes that
    quote '%' characters or other backslashes are removed from the pattern before it is compared t
    file names or has a stem substituted into it. Backslashes that are not in danger of quoting '%'
    characters go unmolested. For example, the pattern the\%weird\\%pattern\\ has `the%weird\' preceding
    the operative '%' character, and 'pattern\\' following it. The final two backslashes are left alone
    because they cannot affect any '%' character.
    This insane behavior probably doesn't matter, but we're compatible just for shits and giggles.
    """

    __slots__ = ('data')

    def __init__(self, s):
        r = []
        i = 0
        slen = len(s)
        while i < slen:
            c = s[i]
            if c == '\\':
                nc = s[i + 1]
                if nc == '%':
                    r.append('%')
                    i += 1
                elif nc == '\\':
                    r.append('\\')
                    i += 1
                else:
                    r.append(c)
            elif c == '%':
                self.data = (''.join(r), s[i + 1:])
                return
            else:
                r.append(c)
            i += 1

        # This is different than (s,) because \% and \\ have been unescaped. Parsing patterns is
        # context-sensitive!
        self.data = (''.join(r), )

    def ismatchany(self):
        return self.data == ('', '')

    def ispattern(self):
        return len(self.data) == 2

    def __hash__(self):
        return self.data.__hash__()

    def __eq__(self, o):
        assert isinstance(o, Pattern)
        return self.data == o.data

    def gettarget(self):
        assert not self.ispattern()
        return self.data[0]

    def hasslash(self):
        return self.data[0].find('/') != -1 or self.data[1].find('/') != -1

    def match(self, word):
        """
        Match this search pattern against a word (string).
        @returns None if the word doesn't match, or the matching stem.
                      If this is a %-less pattern, the stem will always be ''
        """
        d = self.data
        if len(d) == 1:
            if word == d[0]:
                return word
            return None

        d0, d1 = d
        l1 = len(d0)
        l2 = len(d1)
        if len(word) >= l1 + l2 and word.startswith(d0) and word.endswith(d1):
            if l2 == 0:
                return word[l1:]
            return word[l1:-l2]

        return None

    def resolve(self, dir, stem):
        if self.ispattern():
            return dir + self.data[0] + stem + self.data[1]

        return self.data[0]

    def subst(self, replacement, word, mustmatch):
        """
        Given a word, replace the current pattern with the replacement pattern, a la 'patsubst'
        @param mustmatch If true and this pattern doesn't match the word, throw a DataError. Otherwise
                         return word unchanged.
        """
        assert isinstance(replacement, str_type)

        stem = self.match(word)
        if stem is None:
            if mustmatch:
                raise errors.DataError(
                    "target '%s' doesn't match pattern" % (word, ))
            return word

        if not self.ispattern():
            # if we're not a pattern, the replacement is not parsed as a pattern either
            return replacement

        return Pattern(replacement).resolve('', stem)

    def __repr__(self):
        return "<Pattern with data %r>" % (self.data, )

    _backre = re.compile(r'[%\\]')

    def __str__(self):
        if not self.ispattern():
            return self._backre.sub(r'\\\1', self.data[0])

        return self._backre.sub(r'\\\1', self.data[0]) + '%' + self.data[1]


def strip_dotslash(s):
    if s.startswith('./'):
        s = s[2:]
        s = s if s else '.'
    return s


def strip_dotslashes(ss):
    for s in ss:
        yield strip_dotslash(s)


S_TOP = 0  # at the top level
S_FUNC = 1  # expanding a function call
S_VAR = 2  # expanding a variable expansion.
S_FROM = 3  # expanding a variable expansion substitution "from" value
S_TO = 4  # expanding a variable expansion substitution "to" value
S_PAREN = 5  # inside nested parentheses/braces that must be matched


class Frame:
    def __init__(self,
                 state,
                 parent,
                 exp,
                 toks,
                 openb,
                 closeb,
                 func=None,
                 pos=None):
        self.state = state
        self.parent = parent
        self.exp = exp
        self.toks = toks
        self.openb = openb
        self.closeb = closeb
        self.func = func
        self.pos = pos

    def __str__(self):
        return "<state=%i exp=%s toks=%s openb=%s closeb=%s>" % (
            self.state, self.exp, self.toks, self.openb, self.closeb)


_contis = re.compile(r'(?:\s*|((?:\\\\)+))\\\n\s*')


def _replace_contis(m):
    s, e = m.span(1)
    if s == -1:
        return ' '
    return ' '.rjust((e - s) // 2 + 1, '\\')


class Row:

    skipws_re = re.compile(r'\S')
    line_re = re.compile(r'\\*\n')
    comment_re = re.compile(r'\\*\#')

    matching = {'(': ')', '{': '}'}

    @classmethod
    def from_string(cls, s, path):
        return cls(s, 0, len(s), Position(path, 1, 0))

    @classmethod
    def rows_from(cls, s, path):
        off = 0
        line = 1
        count = 0
        for m in cls.line_re.finditer(s):
            count += 1
            start, end = m.span(0)
            if (start - end) % 2 == 0:
                # odd number of backslashes is a continuation
                continue
            yield cls(s, off, end - 1, Position(path, line, 0))
            line += count
            count = 0
            off = end
        yield cls(s, off, len(s), Position(path, line, 0))

    def __init__(self, s, start, end, pos):
        self.s = s
        self.start = start
        self.end = end
        self.pos = pos

    def ifeq(self, offset):
        assert offset <= self.end
        t = self.s[offset]
        assert t in ('(', "'", '"')
        offset += 1
        if t == '(':
            arg1, t, offset = self.parse(offset, (',', ), self.char_gen)
            assert t is not None
            arg1.rstrip()
            offset = self.skip_whitespace(offset)
            arg2, t, offset = self.parse(offset, (')', ), self.char_gen)
            assert t is not None
            s = self.flatten(offset)
            assert not s or s.isspace()
        else:
            arg1, t, offset = self.parse(offset, (t, ), self.char_gen)
            assert t is not None
            offset = self.skip_whitespace(offset)
            assert offset != self.end
            t = self.s[offset]
            assert t in '\'"'
            arg2, t, offset = self.parse(offset + 1, (t, ), self.char_gen)
            s = self.flatten(offset)
            assert not s or s.isspace()
        return EqCondition(arg1, arg2)

    def ifneq(self, offset):
        c = self.ifeq(offset)
        c.expected = False
        return c

    def ifdef(self, offset):
        e, t, offset = self.parse(offset, (), self.char_gen)
        e.rstrip()
        return IfdefCondition(e)

    def ifndef(self, offset):
        c = self.ifdef(offset)
        c.expected = False
        return c

    def position(self, offset):
        assert offset >= self.start and offset <= self.end
        return self.pos.offset(self.s, self.start, offset)

    def skip_whitespace(self, offset):
        m = self._skipws.search(self.s, offset, self.end)
        if m is None:
            return self.end
        return m.start(0)

    def char_gen(self, offset, toks, tgen, comments=True):
        assert offset >= self.start and offset <= self.end
        if offset == self.end:
            return
        s = self.s
        for m in tgen:
            ms, me = m.span(0)
            t = s[ms:me]
            txt = _contis.sub(_replace_contis, s[offset:ms])
            if t[-1] == '#' and comments:
                d = me - ms
                if d % 2:
                    yield txt + t[:(d - 1) // 2], None, None, None
                    return
                else:
                    yield txt + t[-d // 2:], None, None, me
            elif t in toks or (t[0] == '$' and '$' in toks):
                yield txt, t, ms, me
            else:
                yield txt + t, None, None, me
            offset = me
        yield _contis.sub(_replace_contis,
                          s[offset:self.end]), None, None, None

    def cmd_gen(self, offset, toks, tgen):
        assert offset >= self.start and offset <= self.end
        if offset == self.end:
            return
        s = self.s
        for m in tgen:
            ms, me = m.span(0)
            t = s[ms:me]
            txt = s[offset:ms].replace('\n\t', '\n')
            if t in toks or (t[0] == '$' and '$' in toks):
                yield txt, t, ms, me
            else:
                yield txt + t, None, None, me
            offset = me
        yield s[offset:self.end].replace('\n\t', '\n'), None, None, None

    def var_gen(self, offset, toks, tgen):
        assert len(toks)
        assert offset >= self.start and offset <= self.end
        if offset == self.end:
            return
        s = self.s
        for m in tgen:
            ms, me = m.span(0)
            t = s[ms:me]
            if t in toks or (t[0] == '$' and '$' in toks):
                yield s[offset:ms], t, ms, me
            else:
                yield s[offset:me], None, None, me
            offset = me
        yield s[offset:self.end], None, None, None

    def flatten(self, offset):
        assert offset >= self.start and offset <= self.end
        if offset == self.end:
            return ''
        s = _contis.sub(_replace_contis, self.s[offset:self.end])
        elems = []
        offset = 0
        for m in self.comment_re.finditer(s):
            ms, me = m.span(0)
            elems.append(s[offset:ms])
            if (me - ms) % 2:
                elems.append(''.ljust((me - ms - 1) // 2, '\\'))
                return ''.join(elems)
            elems.append(''.ljust((me - ms - 2) // 2, '\\') + '#')
            offset = me
        elems.append(s[offset:])
        return ''.join(elems)

    def parse(self, offset, stopon, gen):
        top = Frame(
            S_TOP,
            None,
            Expansion(pos=self.position(self.start)),
            toks=stopon + ('$', ),
            openb=None,
            closeb=None)
        tgen = _alltokens.finditer(self.s, offset, self.lend)
        r = gen(self, offset, top.toks, tgen)
        while True:
            assert top is not None
            try:
                s, tok, toff, off = next(r)
            except StopIteration:
                break
            top.exp.appendstr(s)
            if tok is None:
                continue
            state = top.state
            if tok[0] == '$':
                if toff + 1 == self.end:
                    break
                p = self.position(toff)
                c = tok[1]
                if c == '$':
                    assert len(tok) == 2
                    top.exp.appendstr('$')
                elif c in ('(', '{'):
                    e = Expansion()
                    m = self.matching[c]
                    if len(tok) > 2:
                        fn = functions.funcmap[tok[2:].rstrip()](p)
                        if len(fn) + 1 == fn.maxargs:
                            ts = (c, m, '$')
                        else:
                            ts = (',', c, m, '$')
                        top = Frame(
                            S_FUNC, top, e, ts, func=fn, openb=c, closeb=m)
                    else:
                        ts = (':', c, m, '$')
                        top = Frame(
                            S_VAR, top, e, ts, openb=c, closeb=m, pos=p)
                else:
                    assert len(tok) == 2
                    e = Expansion.fromstring(c, p)
                    top.exp.appendfunc(functions.VariableRef(p, e))
            elif tok in ('(', '{'):
                assert tok == top.openb
                top.exp.appendstr(tok)
                top = Frame(
                    S_PAREN,
                    top,
                    top.exp, (tok, top.closeb, '$'),
                    openb=tok,
                    closeb=top.closeb,
                    pos=self.position(toff))
            elif state == S_PAREN:
                assert tok == top.closeb
                top.exp.appendstr(tok)
                top = top.parent
            elif state == S_TOP:
                assert top.parent is None
                return top.exp.finish(), tok, off
            elif state == S_FUNC:
                if tok == ',':
                    top.func.append(top.exp.finish())
                    top.exp = Expansion()
                    if len(top.func) + 1 == top.func.maxargs:
                        top.toks = (top.openb, top.closeb, '$')
                elif tok in (')', '}'):
                    fn = top.func
                    fn.append(top.exp.finish())
                    fn.setup()
                    top = top.parent
                    top.exp.appendfunc(fn)
                else:
                    assert False, "Not reached, S_FUNC"
            elif state == S_VAR:
                if tok == ':':
                    top.vname = top.exp
                    top.state = S_FROM
                    top.exp = Expansion()
                    top.toks = ('=', top.openb, top.closeb, '$')
                elif tok in (')', '}'):
                    fn = functions.VariableRef(top.pos, top.exp.finish())
                    top = top.parent
                    top.exp.appendfunc(fn)
                else:
                    assert False, "Not reached, S_VAR"
            elif state == S_FROM:
                if tok == '=':
                    top.sfrom = top.exp
                    top.state = S_TO
                    top.exp = Expansion()
                    top.toks = (top.openb, top.closeb, '$')
                elif tok in (')', '}'):
                    top.vname.appendstr(':')
                    top.vname.concat(top.exp)
                    fn = functions.VariableRef(top.pos, top.vname.finish())
                    top = top.parent
                    top.exp.appendfunc(fn)
                else:
                    assert False, "Not reached, S_FROM"
            elif state == S_TO:
                assert tok in (')', '}'), "Not reached, S_TO"
                fn = functions.SubstitutionRef(top.pos, top.vname.finish(),
                                               top.sfrom.finish(),
                                               top.exp.finish())
                top = top.parent
                top.exp.appendfunc(fn)
            else:
                assert False, "Unexpected state {}".format(top.state)
            if top.parent is not None and gen == r.cmd_gen:
                r = self.char_gen(off, top.toks, tgen, comments=False)
            else:
                r = gen(self, off, top.toks, tgen)
        assert top.parent is None
        assert top.state == S_TOP
        return top.exp.finish(), None, None


class Statement:
    def execute(self, makefile, ctxt):
        pass


class Include(Statement):
    def __init__(self, expansion, required, weak):
        self.exp = expansion
        self.req = required
        self.weak = weak

    def __eq__(self, other):
        if isinstance(other, Include):
            return self.exp == other.exp and self.req == other.req
        return False

    def __str__(self):
        pre = '' if self.required else '-'
        return '{}include {}'.format(pre, self.exp)

    def execute(self, makefile, ctxt):
        fs = self.exp.resolvesplit(makefile, makefile.variables)
        for f in fs:
            makefile.include(f, self.req, pos=self.exp.pos, weak=self.weak)


class SetVariable(Statement):
    def __init__(self, vnameexp, token, value, valueloc, tgt, src=None):
        if src is None:
            src = Variables.MAKEFILE
        self.vnameexp = vnameexp
        self.token = token
        self.value = value
        self.valueloc = valueloc
        self.tgt = tgt
        self.src = src

    def execute(self, makefile, context):
        vname = self.vnameexp.resolvestr(makefile, makefile.variables)
        if len(vname) == 0:
            raise RuntimeError("Empty variable name", self.vnameexp.loc)

        if self.tgt is None:
            setvariables = [makefile.variables]
        else:
            setvariables = []

            targets = [
                Pattern(t) for t in strip_dotslashes(
                    self.tgt.resolvesplit(makefile, makefile.variables))
            ]
            for t in targets:
                if t.ispattern():
                    setvariables.append(makefile.getpatternvariables(t))
                else:
                    setvariables.append(
                        makefile.gettarget(t.gettarget()).variables)

        for v in setvariables:
            if self.token == '+=':
                v.append(vname, self.src, self.value, makefile.variables,
                         makefile)
                continue

            if self.token == '?=':
                kind = Variables.RECURS
                oldkind, oldsrc, oldval = v.get(vname, expand=False)
                if oldval is not None:
                    continue
                value = self.value
            elif self.token == '=':
                kind = Variables.RECURS
                value = self.value
            else:
                assert self.token == ':='

                kind = Variables.SIMPLE
                d = parser.Data.fromstring(self.value, self.valueloc)
                e, t, o = d.parse(0, (), d.var_gen)
                value = e.resolvestr(makefile, makefile.variables)

            v.set(vname, kind, self.src, value)

    def __eq__(self, other):
        if not isinstance(other, SetVariable):
            return False

        return self.vnameexp == other.vnameexp \
                and self.token == other.token \
                and self.value == other.value \
                and self.tgt == other.tgt \
                and self.src == other.src

    def to_src(self):
        chars = []
        for i in range(0, len(self.value)):
            c = self.value[i]

            # Literal # is escaped in variable assignment otherwise it would be
            # a comment.
            if c == '#':
                # If a backslash precedes this, we need to escape it as well.
                if i > 0 and self.value[i - 1] == '\\':
                    chars.append('\\')

                chars.append('\\#')
                continue

            chars.append(c)

        value = ''.join(chars)

        prefix = ''
        if self.src == Variables.OVERRIDE:
            prefix = 'override '

        # SetVariable come in two kinds: simple and target-specific.

        # We handle the target-specific syntax first.
        if self.tgt is not None:
            return '%s: %s %s %s' % (self.tgt.to_src(), self.vnameexp.to_src(),
                                     self.token, value)

        # The variable could be multi-line or have leading whitespace. For
        # regular variable assignment, whitespace after the token but before
        # the value is ignored. If we see leading whitespace in the value here,
        # the variable must have come from a define.
        if value.count('\n') > 0 or (len(value) and value[0].isspace()):
            # The parser holds the token in vnameexp for whatever reason.
            return '%sdefine %s\n%s\nendef' % (prefix, self.vnameexp.to_src(),
                                               value)

        return '%s%s %s %s' % (prefix, self.vnameexp.to_src(), self.token,
                               value)


class Rule(Statement):
    def __init__(self, target, depend, always):
        self.tgt = target
        self.dep = depend
        self.always = always

    def __eq__(self, other):
        if isinstance(other, Rule):
            return (self.tgt == other.tgt and self.dep == other.dep
                    and self.always == other.always)
        return False

    def __str__(self):
        sep = '::' if self.always else ':'
        ds = str(self.dep)
        if len(ds) > 0 and not ds[0].isspace():
            sep += ' '
        return '\n{}{}{}' % (self.tgt, sep, ds)

    def execute(self, makefile, ctxt):
        if ctxt.weak:
            ds = self.dep.resolvesplit(makefile, makefile.variables)
            if ds:
                ts = strip_dotslashes(
                    self.tgt.resolvesplit(makefile, makefile.variables))
                rule = Rule(
                    list(strip_dotslashes(ds)),
                    self.always,
                    loc=self.tgt.loc,
                    weakdeps=True)
                for t in ts:
                    makefile.gettarget(t).addrule(rule)
                    makefile.foundtarget(t)
                ctxt.currule = rule
        else:
            ts = strip_dotslashes(
                self.tgt.resolvesplit(makefile, makefile.variables))
            ts = [Pattern(p) for p in _expandwildcards(makefile, ts)]
            if ts:
                pats = set((t.ispattern() for t in ts))
                if len(pats) == 2:
                    raise RuntimeError('Mixed implicit and normal rule',
                                       self.tgt.loc)
                ds = list(
                    _expandwildcards(
                        makefile,
                        strip_dotslashes(
                            self.dep.resolvesplit(makefile,
                                                  makefile.variables))))
                pat, = pats
                if pat:
                    reqs = [Pattern(d) for d in ds]
                    rule = PatternRule(ts, reqs, self.always, loc=self.tgt.loc)
                    makefile.appendimplicitrule(rule)
                else:
                    rule = Rule(
                        ds, self.always, loc=self.tgt.loc, weakdeps=False)
                    for t in ts:
                        makefile.gettarget(t.gettarget()).addrule(rule)
                    makefile.foundtarget(ts[0].gettarget())
                    ctxt.currule = rule


class Command(Statement):
    def __init__(self, expansion):
        self.exp = expansion

    def __eq__(self, other):
        if isinstance(other, Command):
            return self.exp == other.exp
        return False

    def __str__(self):
        s = str(self.exp)
        return '\n'.join(['\t{}'.format(ln for ln in s.split('\n'))])

    def execute(self, makefile, ctxt):
        assert ctxt.currule is not None
        if ctxt.weak:
            raise RuntimeError("rules not allowed in includedeps",
                               self.exp.pos)
        ctxt.currule.addcommand(self.exp)


_conditionkeywords = {
    'ifeq': ifeq,
    'ifneq': ifneq,
    'ifdef': ifdef,
    'ifndef': ifndef
}

_conditiontokens = tuple(_conditionkeywords.keys())
_conditionre = re.compile(r'(%s)(?:$|\s+)' % '|'.join(_conditiontokens))

_directivestokenlist = _conditiontokens + \
    ('else', 'endif', 'define', 'endef', 'override', 'include', '-include',
     'includedeps', '-includedeps', 'vpath', 'export', 'unexport')

_directivesre = re.compile(r'(%s)(?:$|\s+)' % '|'.join(_directivestokenlist))

_varsettokens = (':=', '+=', '?=', '=')

_depfilesplitter = re.compile(r':(?![\\/])')
_vars = re.compile(r'\$\((\w+)\)')


class Statements:
    def __init__(self):
        self.cache = {}

    def from_path(self, path):
        t = path.stat().st_mtime
        try:
            ss, p = self.cache[path]
            if t != p:
                ss = None
        except KeyError:
            ss = None
        if ss is None:
            with open(path) as f:
                ss = self.from_string(f.read(), path)
            self.cache[path] = ss, t
        return ss


def from_string(self, s, path):
    rule = False
    stack = [StatementList()]
    for r in Row.rows_from(s, path):
        off = r.start
        if rule and off < r.end and r.s[off] == '\t':
            e, tok, off = r.parse(off + 1, (), r.cmd_gen)
            assert tok is None
            assert off is None
            stack[-1].append(Command(e))
            continue
        off = r.skip_whitespace(off)
        if off is None:
            continue
        m = _directivesre.match(r.s, off, r.end)
        if m is not None:
            key = m.group(1)
            off = m.end(0)
            if key == 'endif':
                s = r.flatten(off)
                assert not s or s.isspace()
                assert len(stack) > 1
                stack.pop().endloc = r.position(off)
                continue
            if key == 'else':
                assert len(stack) > 1
                m = _conditionre.match(r.s, off, r.end)
                if m is None:
                    s = r.flatten(off)
                    assert not s or s.isspace()
                    stack[-1].addcondition(r.position(off), ElseCondition())
                else:
                    key = m.group(1)
                    startoff = off
                    off = r.skip_whitespace(m.end(1))
                    c = _conditionkeywords[key](r, off)
                    stack[-1].addcondition(r.getloc(startoff), c)
                continue
            if key in _conditionkeywords:
                c = _conditionkeywords[key](r, off)
                cb = ConditionBlock(r.getloc(r.start), c)
                stack[-1].append(cb)
                stack.append(cb)
                continue
            if key == 'endef':
                raise RuntimeError("endef without matching define",
                                   r.getloc(off))
            if key == 'define':
                rule = False
                vname, t, i = r.parse(off, (), r.char_gen)
                vname.rstrip()
                startloc = r.getloc(r.start)
                value = iterdefinelines(fdlines, startloc)
                stack[-1].append(
                    SetVariable(
                        vname,
                        value=value,
                        valueloc=startloc,
                        token='=',
                        tgt=None))
                continue
            if key in ('include', '-include', 'includedeps', '-includedeps'):
                req = True
                if key.startswith('-'):
                    key = key[1:]
                    req = False
                rule = False
                incfile, t, off = r.parse(off, (), r.char_gen)
                stack[-1].append(Include(incfile, req, (key == 'includedeps')))
                continue
            if key == 'vpath':
                rule = False
                e, t, off = r.parse(off, (), r.char_gen)
                stack[-1].append(VPathDirective(e))
                continue
            if key == 'override':
                rule = False
                vname, tok, off = r.parse(off, _varsettokens, r.char_gen)
                vname.lstrip()
                vname.rstrip()
                assert tok
                value = r.flatten(off).lstrip()
                stack[-1].append(
                    SetVariable(
                        vname,
                        value=value,
                        valueloc=r.getloc(off),
                        token=tok,
                        tgt=None,
                        src=Variables.OVERRIDE))
                continue
            if key == 'export':
                rule = False
                e, tok, off = r.parse(off, _varsettokens, r.char_gen)
                e.lstrip()
                e.rstrip()
                if tok is None:
                    stack[-1].append(ExportDirective(e, concurrent_set=False))
                else:
                    stack[-1].append(ExportDirective(e, concurrent_set=True))
                    value = r.flatten(off).lstrip()
                    stack[-1].append(
                        SetVariable(
                            e,
                            value=value,
                            valueloc=r.getloc(off),
                            token=tok,
                            tgt=None))
                continue
            if key == 'unexport':
                e, tok, off = r.parse(off, (), r.char_gen)
                stack[-1].append(UnexportDirective(e))
                continue
        e, tok, off = r.parse(r, off, _varsettokens + ('::', ':'), r.char_gen)
        if tok is None:
            e.rstrip()
            e.lstrip()
            if not e.isempty():
                stack[-1].append(EmptyDirective(e))
            continue
        rule = False
        if tok in _varsettokens:
            e.lstrip()
            e.rstrip()
            value = r.flatten(off).lstrip()
            stack[-1].append(
                SetVariable(
                    e,
                    value=value,
                    valueloc=r.getloc(off),
                    token=tok,
                    tgt=None))
        else:
            always = tok == '::'
            # `e` is targets or target patterns, which can end up as
            # * a rule
            # * an implicit rule
            # * a static pattern rule
            # * a target-specific variable definition
            # * a pattern-specific variable definition
            # any of the rules may have order-only prerequisites
            # delimited by |, and a command delimited by ;
            targets = e
            e, tok, off = r.parse(off, _varsettokens + (':', '|', ';'),
                                  r.char_gen)
            if tok in (None, ';'):
                stack[-1].append(Rule(targets, e, always))
                rule = True
                if tok == ';':
                    off = r.skip_whitespace(off)
                    e, t, off = r.parse(off, (), r.cmd_gen)
                    stack[-1].append(Command(e))
            elif tok in _varsettokens:
                e.lstrip()
                e.rstrip()
                value = r.flatten(off).lstrip()
                stack[-1].append(
                    SetVariable(
                        e,
                        value=value,
                        valueloc=r.getloc(off),
                        token=tok,
                        tgt=targets))
            elif tok == '|':
                raise RuntimeError('order-only prerequisites not implemented',
                                   r.getloc(off))
            else:
                assert tok == ':'
                pattern = e
                deps, tok, off = r.parse(off, (';', ), r.char_gen)
                stack[-1].append(
                    StaticPatternRule(targets, pattern, deps, always))
                rule = True
                if tok == ';':
                    off = r.skip_whitespace(off)
                    e, tok, off = r.parse(off, (), r.cmd_gen)
                    stack[-1].append(Command(e))
    assert len(stack) == 1
    return stack[0]


def _expandwildcards(makefile, tlist):
    for t in tlist:
        if not hasglob(t):
            yield t
        else:
            l = glob(makefile.workdir, t)
            for r in l:
                yield r


_flagescape = re.compile(r'([\s\\])')


def parsecommandlineargs(args):
    """
    Given a set of arguments from a command-line invocation of make,
    parse out the variable definitions and return (stmts, arglist, overridestr)
    """

    overrides = []
    stmts = StatementList()
    r = []
    for i in range(0, len(args)):
        a = args[i]

        vname, t, val = util.strpartition(a, ':=')
        if t == '':
            vname, t, val = util.strpartition(a, '=')
        if t != '':
            overrides.append(_flagescape.sub(r'\\\1', a))

            vname = vname.strip()
            vnameexp = Expansion.fromstring(vname, "Command-line argument")

            stmts.append(ExportDirective(vnameexp, concurrent_set=True))
            stmts.append(
                SetVariable(
                    vnameexp,
                    token=t,
                    value=val,
                    valueloc=Position('<command-line>', i,
                                      len(vname) + len(t)),
                    targetexp=None,
                    src=Variables.CMDLINE))
        else:
            r.append(strip_dotslash(a))

    return stmts, r, ' '.join(overrides)


class StaticPatternRule(Statement):
    """
    Static pattern rules are rules which specify multiple targets based on a
    string pattern.
    See https://www.gnu.org/software/make/manual/make.html#Static-Pattern
    They are like `Rule` instances except an added property, `patternexp` is
    present. It contains the Expansion which represents the rule pattern.
    """
    __slots__ = ('tgt', 'patternexp', 'dep', 'always')

    def __init__(self, tgt, patternexp, dep, always):
        self.tgt = tgt
        self.patternexp = patternexp
        self.dep = dep
        self.always = always

    def execute(self, makefile, context):
        if context.weak:
            raise RuntimeError(
                "Static pattern rules not allowed in includedeps",
                self.tgt.loc)

        targets = list(
            _expandwildcards(
                makefile,
                strip_dotslashes(
                    self.tgt.resolvesplit(makefile, makefile.variables))))

        if not len(targets):
            context.currule = DummyRule()
            return

        patterns = list(
            strip_dotslashes(
                self.patternexp.resolvesplit(makefile, makefile.variables)))
        if len(patterns) != 1:
            raise RuntimeError(
                "Static pattern rules must have a single pattern",
                self.patternexp.loc)
        pattern = Pattern(patterns[0])

        deps = [
            Pattern(p) for p in _expandwildcards(
                makefile,
                strip_dotslashes(
                    self.dep.resolvesplit(makefile, makefile.variables)))
        ]

        rule = PatternRule([pattern], deps, self.always, loc=self.tgt.loc)

        for t in targets:
            if Pattern(t).ispattern():
                raise RuntimeError(
                    "Target '%s' of a static pattern rule must not be a pattern"
                    % (t, ), self.tgt.loc)
            stem = pattern.match(t)
            if stem is None:
                raise RuntimeError(
                    "Target '%s' does not match the static pattern '%s'" %
                    (t, pattern), self.tgt.loc)
            makefile.gettarget(t).addrule(
                PatternRuleInstance(rule, '', stem, pattern.ismatchany()))

        makefile.foundtarget(targets[0])
        context.currule = rule

    def to_src(self):
        sep = ':'

        if self.always:
            sep = '::'

        pattern = self.patternexp.to_src()
        deps = self.dep.to_src()

        if len(pattern) > 0 and pattern[0] not in (' ', '\t'):
            sep += ' '

        return '\n%s%s%s:%s' % (self.tgt.to_src(escape_variables=True), sep,
                                pattern, deps)

    def __eq__(self, other):
        if not isinstance(other, StaticPatternRule):
            return False
        return (self.tgt == other.tgt and self.patternexp == other.patternexp
                and self.dep == other.dep and self.always == other.always)


class Condition:
    def __ne__(self, other):
        return not self.__eq__(other)


class EqCondition(Condition):
    def __init__(self, exp1, exp2):
        self.expected = True
        self.exp1 = exp1
        self.exp2 = exp2

    def evaluate(self, makefile):
        r1 = self.exp1.resolvestr(makefile, makefile.variables)
        r2 = self.exp2.resolvestr(makefile, makefile.variables)
        return (r1 == r2) == self.expected

    def __str__(self):
        return "ifeq (expected=%s) %s %s" % (self.expected, self.exp1,
                                             self.exp2)

    def __eq__(self, other):
        if isinstance(other, EqCondition):
            return (self.exp1 == other.exp1 and self.exp2 == other.exp2
                    and self.expected == other.expected)
        return False


class IfdefCondition(Condition):
    def __init__(self, exp):
        self.expected = True
        self.exp = exp

    def evaluate(self, makefile):
        vname = self.exp.resolvestr(makefile, makefile.variables)
        kind, src, value = makefile.variables.get(vname, expand=False)

        if value is None:
            return not self.expected

        return (len(value) > 0) == self.expected

    def __str__(self):
        return "ifdef (expected=%s) %s" % (self.expected, self.exp)

    def __eq__(self, other):
        if isinstance(other, IfdefCondition):
            return self.exp == other.exp and self.expected == other.expected
        return False


class ElseCondition(Condition):
    def evaluate(self, makefile):
        return True

    def __str__(self):
        return "else"

    def __eq__(self, other):
        return isinstance(other, ElseCondition)


class ConditionBlock(Statement):
    """
    A set of related Conditions.
    This is essentially a list of 2-tuples of (Condition, list(Statement)).
    The parser creates a ConditionBlock for all statements related to the same
    conditional group. If iterating over the parser's output, where you think
    you would see an ifeq, you will see a ConditionBlock containing an IfEq. In
    other words, the parser collapses separate statements into this container
    class.
    ConditionBlock instances may exist within other ConditionBlock if the
    conditional logic is multiple levels deep.
    """
    __slots__ = ('loc', '_groups')

    def __init__(self, loc, condition):
        self.loc = loc
        self._groups = []
        self.addcondition(loc, condition)

    def getloc(self):
        return self.loc

    def addcondition(self, loc, condition):
        assert isinstance(condition, Condition)
        condition.loc = loc

        if len(self._groups) and isinstance(self._groups[-1][0],
                                            ElseCondition):
            raise RuntimeError(
                "Multiple else conditions for block starting at %s" % self.loc,
                loc)

        self._groups.append((condition, StatementList()))

    def append(self, statement):
        self._groups[-1][1].append(statement)

    def execute(self, makefile, context):
        i = 0
        for c, statements in self._groups:
            if c.evaluate(makefile):
                _log.debug("Condition at %s met by clause #%i", self.loc, i)
                statements.execute(makefile, context)
                return

            i += 1

    def dump(self, fd, indent):
        print("%sConditionBlock" % (indent, ), file=fd)

        indent2 = indent + '  '
        for c, statements in self._groups:
            print("%s Condition %s" % (indent, c), file=fd)
            statements.dump(fd, indent2)
            print("%s ~Condition" % (indent, ), file=fd)
        print("%s~ConditionBlock" % (indent, ), file=fd)

    def to_src(self):
        lines = []
        index = 0
        for condition, statements in self:
            lines.append(ConditionBlock.condition_src(condition, index))
            index += 1

            for statement in statements:
                lines.append(statement.to_src())

        lines.append('endif')

        return '\n'.join(lines)

    def __eq__(self, other):
        if not isinstance(other, ConditionBlock):
            return False

        if len(self) != len(other):
            return False

        for i in range(0, len(self)):
            our_condition, our_statements = self[i]
            other_condition, other_statements = other[i]

            if our_condition != other_condition:
                return False

            if our_statements != other_statements:
                return False

        return True

    @staticmethod
    def condition_src(statement, index):
        """Convert a condition to its src representation.
        The index argument defines the index of this condition inside a
        ConditionBlock. If it is greater than 0, an "else" will be prepended
        to the result, if necessary.
        """
        prefix = ''
        if isinstance(statement, (EqCondition, IfdefCondition)) and index > 0:
            prefix = 'else '

        if isinstance(statement, IfdefCondition):
            s = statement.exp.s

            if statement.expected:
                return '%sifdef %s' % (prefix, s)

            return '%sifndef %s' % (prefix, s)

        if isinstance(statement, EqCondition):
            args = [
                statement.exp1.to_src(escape_comments=True),
                statement.exp2.to_src(escape_comments=True)
            ]

            use_quotes = False
            single_quote_present = False
            double_quote_present = False
            for i, arg in enumerate(args):
                if len(arg) > 0 and (arg[0].isspace() or arg[-1].isspace()):
                    use_quotes = True

                    if "'" in arg:
                        single_quote_present = True

                    if '"' in arg:
                        double_quote_present = True

            # Quote everything if needed.
            if single_quote_present and double_quote_present:
                raise Exception(
                    'Cannot format condition with multiple quotes.')

            if use_quotes:
                for i, arg in enumerate(args):
                    # Double to single quotes.
                    if single_quote_present:
                        args[i] = '"' + arg + '"'
                    else:
                        args[i] = "'" + arg + "'"

            body = None
            if use_quotes:
                body = ' '.join(args)
            else:
                body = '(%s)' % ','.join(args)

            if statement.expected:
                return '%sifeq %s' % (prefix, body)

            return '%sifneq %s' % (prefix, body)

        if isinstance(statement, ElseCondition):
            return 'else'

        raise Exception(
            'Unhandled Condition statement: %s' % statement.__class__)

    def __iter__(self):
        return iter(self._groups)

    def __len__(self):
        return len(self._groups)

    def __getitem__(self, i):
        return self._groups[i]


class VPathDirective(Statement):
    def __init__(self, exp):
        assert isinstance(exp, (Expansion, StringExpansion))
        self.exp = exp

    def execute(self, makefile, context):
        words = list(
            strip_dotslashes(
                self.exp.resolvesplit(makefile, makefile.variables)))
        if len(words) == 0:
            makefile.clearallvpaths()
        else:
            pattern = Pattern(words[0])
            mpaths = words[1:]

            if len(mpaths) == 0:
                makefile.clearvpath(pattern)
            else:
                dirs = []
                for mpath in mpaths:
                    dirs.extend(
                        (dir for dir in mpath.split(os.pathsep) if dir != ''))
                if len(dirs):
                    makefile.addvpath(pattern, dirs)

    def to_src(self):
        return 'vpath %s' % self.exp.to_src()

    def __eq__(self, other):
        if isinstance(other, VPathDirective):
            return self.exp == other.exp
        return False


class ExportDirective(Statement):
    """
    Represents the "export" directive.
    This is used to control exporting variables to sub makes.
    See https://www.gnu.org/software/make/manual/make.html#Variables_002fRecursion
    The `concurrent_set` field defines whether this statement occurred with or
    without a variable assignment. If False, no variable assignment was
    present. If True, the SetVariable immediately following this statement
    originally came from this export directive (the parser splits it into
    multiple statements).
    """

    def __init__(self, exp, concurrent_set):
        self.exp = exp
        self.concurrent_set = concurrent_set

    def execute(self, makefile, context):
        if self.concurrent_set:
            vlist = [self.exp.resolvestr(makefile, makefile.variables)]
        else:
            vlist = list(self.exp.resolvesplit(makefile, makefile.variables))
            if not len(vlist):
                raise RuntimeError("Exporting all variables is not supported",
                                   self.exp.loc)

        for v in vlist:
            makefile.exportedvars[v] = True

    def to_src(self):
        return ('export %s' % self.exp.to_src()).rstrip()

    def __eq__(self, other):
        if isinstance(other, ExportDirective):
            return self.exp == other.exp
        return False


class UnexportDirective(Statement):
    def __init__(self, exp):
        self.exp = exp

    def execute(self, makefile, context):
        vlist = list(self.exp.resolvesplit(makefile, makefile.variables))
        for v in vlist:
            makefile.exportedvars[v] = False

    def to_src(self):
        return 'unexport %s' % self.exp.to_src()

    def __eq__(self, other):
        if isinstance(other, UnexportDirective):
            return self.exp == other.exp
        return False


class EmptyDirective(Statement):
    def __init__(self, exp):
        self.exp = exp

    def execute(self, makefile, context):
        v = self.exp.resolvestr(makefile, makefile.variables)
        if v.strip() != '':
            raise RuntimeError("Line expands to non-empty value", self.exp.loc)

    def to_src(self):
        return self.exp.to_src()

    def __eq__(self, other):
        if isinstance(other, EmptyDirective):
            return self.exp == other.exp
        return False


class _EvalContext:
    def __init__(self, weak):
        self.weak = weak


def iterstatements(stmts):
    for s in stmts:
        yield s
        if isinstance(s, ConditionBlock):
            for c, sl in s:
                for s2 in iterstatements(sl):
                    yield s2


_alltokens = re.compile(
    r'''\\*\# | # hash mark preceeded by any number of backslashes
                            := |
                            \+= |
                            \?= |
                            :: |
                            (?:\$(?:$|[\(\{](?:%s)\s+|.)) | # dollar sign followed by EOF, a function keyword with whitespace, or any character
                            :(?![\\/]) | # colon followed by anything except a slash (Windows path detection)
                            [=#{}();,|'"]''' % '|'.join(
        functions.functionmap.keys()), re.VERBOSE)

_redefines = re.compile(r'\s*define|\s*endef')


def iterdefinelines(it, startloc):
    """
    Process the insides of a define. Most characters are included literally. Escaped newlines are treated
    as they would be in makefile syntax. Internal define/endef pairs are ignored.
    """
    results = []
    definecount = 1
    for d in it:
        m = _redefines.match(d.s, d.lstart, d.lend)
        if m is not None:
            directive = m.group(0).strip()
            if directive == 'endef':
                definecount -= 1
                if definecount == 0:
                    return _contis.sub(_replace_contis, '\n'.join(results))
            else:
                definecount += 1
        results.append(d.s[d.lstart:d.lend])
    assert False, "define without matching endef"


def parsedepfile(pathname):
    """
    Parse a filename listing only depencencies into a parserdata.StatementList.
    Simple variable references are allowed in such files.
    """

    def continuation_iter(lines):
        current_line = []
        for line in lines:
            line = line.rstrip()
            if line.endswith("\\"):
                current_line.append(line.rstrip("\\"))
                continue
            if not len(line):
                continue
            current_line.append(line)
            yield ''.join(current_line)
            current_line = []
        if current_line:
            yield ''.join(current_line)

    def get_expansion(s):
        if '$' in s:
            expansion = Expansion()
            # for an input like e.g. "foo $(bar) baz",
            # _vars.split returns ["foo", "bar", "baz"]
            # every other element is a variable name.
            for i, element in enumerate(_vars.split(s)):
                if i % 2:
                    expansion.appendfunc(
                        functions.VariableRef(None,
                                              StringExpansion(element, None)))
                elif element:
                    expansion.appendstr(element)

            return expansion

        return StringExpansion(s, None)

    pathname = os.path.realpath(pathname)
    stmts = StatementList()
    for line in continuation_iter(open(pathname).readlines()):
        target, deps = _depfilesplitter.split(line, 1)
        stmts.append(Rule(get_expansion(target), get_expansion(deps), False))
    return stmts


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
