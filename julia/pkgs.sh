# julia

init() {
    gpg="3673DF529D9049477F76B37566E3C7DC03D6E495"
    url="https://julialang-s3.julialang.org/bin/linux/x64/"
    v=$JL_OLD_VER
    fetch \
        $gpg \
        $url/$(echo $v | cut -d. -f1-2) \
        "julia-$v-linux-x86_64.tar.gz" \
        "f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1"
    v=$JL_NEW_VER
    fetch \
        $gpg \
        $url/$(echo $v | cut -d. -f1-2) \
        "julia-$v-linux-x86_64.tar.gz" \
        "30b214c7f544c6589a20104eaa6764eb368cadac5fa834b7454b747043e5a2b8"
}

run() {
    v=$1
    d=$2/julia
    mkdir -p $d
    tar -xzf "julia-$v-linux-x86_64.tar.gz" -C $d --strip-components 1
}

clean() {
    rm -rf pkgs
}
