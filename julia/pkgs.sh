# julia

init() {
    mkdir -p pkgs
    cd pkgs
    for v in 1.5.3 1.6.0-beta1; do
        d="$(echo "$v" | cut -d. -f1-2)"
        if [ $v = "1.5.3" ]; then
            sha="f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1"
        else
            sha="30b214c7f544c6589a20104eaa6764eb368cadac5fa834b7454b747043e5a2b8"
        fi
        fetch \
            "3673DF529D9049477F76B37566E3C7DC03D6E495" \
            "https://julialang-s3.julialang.org/bin/linux/x64/$d" \
            "julia-$v-linux-x86_64.tar.gz" \
            sha
    done
}

run() {
    cd pkgs || exit
    mkdir -p "$2"
    tar -xzf "julia-$1-linux-x86_64.tar.gz" -C "$2" --strip-components 1
}

clean() {
    rm -rf pkgs
}
