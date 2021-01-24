# rust

arch="x86_64-unknown-linux-gnu"

init() {
    fetch \
        "" \
        "https://static.rust-lang.org/rustup/archive/1.23.1/$arch" \
        "rustup-init" \
        "ed7773edaf1d289656bdec2aacad12413b38ad0193fff54b2231f5140a4b07c5"
}

run() {
    v=$RUST_VER
    d=$2
    export RUST_VERSION=$v \
        RUSTUP_HOME=$d/rustup \
        CARGO_HOME=$d/cargo \
        PATH=$d/cargo/bin:$PATH
    chmod +x rustup-init
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $v --default-host $arch
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME
    rustup --version
    cargo --version
    rustc --version
}

clean() {
    rm -rf pkgs
}
