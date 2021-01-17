#!/bin/bash
set -Eeuxo pipefail

init() {
    mkdir -p pkgs
    cd pkgs

    base="ubuntu-hirsute-core-cloudimg-amd64"
    tar="$base-root.tar.gz"
    url="https://partner-images.canonical.com/core/hirsute/current"
		wget -qN "$url/"{{MD5,SHA{1,256}}SUMS{,.gpg},"$base.manifest",'unpacked/build-info.txt'}
		wget -N --progress=dot:giga "$url/$tar"

  	export GNUPGHOME="$(mktemp -d)"
    GPG=D2EB44626FDDC30B513D5BB71A5D6C4C7DB87C81
	  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG"
  	for s in sha256 sha1 md5; do
        f="${s^^}SUMS"
        gpg --batch --verify "$f.gpg" "$f"
        c="${s}sum"
        grep " *$tar\$" "$f" | "$c" -c -
	  done
    command -v gpgconf > /dev/null && gpgconf --kill all
    rm -rf "$GNUPGHOME"
}

load() {
    aptMark="$(apt-mark showmanual)"
    if ! command -v gpg > /dev/null; then 
        apt-get update
        apt-get install -y --no-install-recommends wget gnupg dirmngr
        rm -rf /var/lib/apt/lists/*
    fi; 

    base="ubuntu-hirsute-core-cloudimg-amd64"
    tar="$base-root.tar.gz"
    url="https://partner-images.canonical.com/core/hirsute/current"

	  cd pkgs
		wget -qN "$url/"{{MD5,SHA{1,256}}SUMS{,.gpg},"$base.manifest",'unpacked/build-info.txt'}
		wget -N --progress=dot:giga "$url/$tar"

  	export GNUPGHOME="$(mktemp -d)"
    GPG=D2EB44626FDDC30B513D5BB71A5D6C4C7DB87C81
	  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG"
  	for s in sha256 sha1 md5; do
        f="${s^^}SUMS"
        gpg --batch --verify "$f.gpg" "$f"
        c="${s}sum"
        grep " *$tar\$" "$f" | "$c" -c -
	  done
    command -v gpgconf > /dev/null && gpgconf --kill all
    rm -rf "$GNUPGHOME"

    apt-mark auto '.*' > /dev/null
    [ -z "$aptMark" ] || apt-mark manual $aptMark
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
}

reset() {
    rm -rf pkgs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-l] [-c]"
}

main() {
    local OPTIND=1
    local INIT=
    local LOAD=
    local CLEAN=
    while getopts "ilch" opt; do
              case $opt in
                  i) INIT=true;;
                  l) LOAD=true;;
                  c) CLEAN=true;;
                  *) show_usage; return 1;;
              esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
          init
    fi
    if [[ -n "$LOAD" ]]; then
          load
    fi
    if [[ -n "$CLEAN" ]]; then
          clean
    fi
}

main "$@"
