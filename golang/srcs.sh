# golang

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            git clone -q https://github.com/golang/go.git upstream
        fi
        (cd upstream || exit
            git branch -f qold $GOLANG_VER
            git checkout -q --track -B qnew master
            git reset -q --hard
            git clean -qxfd
            git pull -q
        )
    else
        mv srcs/qpx.sh .
        rm -rf srcs
        git clone -qb $1 ./upstream srcs
        mv qpx.sh srcs/
    fi
}

run() {
    v=$GOLANG_VER
    d=$2
    goEnv="$(go env | sed -rn -e '/^GO(OS|ARCH|ARM|386)=/s//export \0/p')"
		eval "$goEnv"; [ -n "$GOOS" ]; [ -n "$GOARCH" ]
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
