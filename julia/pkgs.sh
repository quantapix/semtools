# julia

# checksums at https://julialang-s3.julialang.org/bin/checksums

init() {
    gpg="3673DF529D9049477F76B37566E3C7DC03D6E495"
    v1=$JL_OLD_VER
    fetch \
        $gpg \
        "https://julialang-s3.julialang.org/bin/linux/x64"/$(echo $v1 | cut -d. -f1-2) \
        "julia-$v1-linux-x86_64.tar.gz" \
        "f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1"
    v2=$JL_NEW_VER
    fetch \
        $gpg \
        "https://julialang-s3.julialang.org/bin/linux/x64"/$(echo $v2 | cut -d. -f1-2) \
        "julia-$v2-linux-x86_64.tar.gz" \
        "72847bd2b4d4db9d5970512f79fd5a7f76ad56cf0f2ea5a80eff032364b19c8b"
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
