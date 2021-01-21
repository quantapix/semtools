# julia

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/JuliaLang/julia.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold v1.6.0-beta1
            git checkout -q --track -B qnew master
            git reset -q --hard
            git clean -qxfd
            git pull -q
        )
    else
        rm -rf srcs
        git clone -qb $1 ./upstream srcs
    fi
}

run() {
    goEnv="$(go env | sed -rn -e '/^GO(OS|ARCH|ARM|386)=/s//export \0/p')"
		eval "$goEnv"; [ -n "$GOOS" ]; [ -n "$GOARCH" ]
    cd srcs
		./make.bash
    go install std
		go install -race std
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
    go version
}

clean() {
    rm -rf srcs
}
