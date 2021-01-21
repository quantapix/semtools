# rust

arch="x86_64-unknown-linux-gnu"

init() {
    mkdir -p pkgs
    cd pkgs
    fetch \
        "" \
        "https://static.rust-lang.org/rustup/archive/1.23.1/$arch" \
        "rustup-init" \
        "ed7773edaf1d289656bdec2aacad12413b38ad0193fff54b2231f5140a4b07c5"
}

run() {
    cd pkgs || exit
    export RUST_VERSION=$1 \
        RUSTUP_HOME=$2/rustup \
        CARGO_HOME=$2/cargo \
        PATH=$2/cargo/bin:$PATH
    chmod +x rustup-init
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host $arch
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME
    rustup --version
    cargo --version
    rustc --version
}

clean() {
    rm -rf pkgs
}
