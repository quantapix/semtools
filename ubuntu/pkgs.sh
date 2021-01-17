#!/bin/bash
set -Eeuxo pipefail

init() {
    export GNUPGHOME="$(mktemp -d)"
    GPG=D2EB44626FDDC30B513D5BB71A5D6C4C7DB87C81
	  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG"

    for v in focal hirsute; do
        base="ubuntu-$v-core-cloudimg-amd64"
        tar="$base-root.tar.gz"
        url="https://partner-images.canonical.com/core/$v/current"
        mkdir -p pkgs/$v
        (cd pkgs/$v
            wget -qN "$url/"{{MD5,SHA{1,256}}SUMS{,.gpg},"$base.manifest",'unpacked/build-info.txt'}
            wget -N --progress=dot:giga "$url/$tar"
            for s in sha256 sha1 md5; do
                f="${s^^}SUMS"
                gpg --batch --verify "$f.gpg" "$f"
                c="${s}sum"
                grep " *$tar\$" "$f" | "$c" -c -
            done)
    done

    command -v gpgconf > /dev/null && gpgconf --kill all
    rm -rf "$GNUPGHOME"
}

load() {
    echo '#!/bin/sh' > /usr/sbin/policy-rc.d
    echo 'exit 101' >> /usr/sbin/policy-rc.d
    chmod +x /usr/sbin/policy-rc.d

    dpkg-divert --local --rename --add /sbin/initctl
    cp -a /usr/sbin/policy-rc.d /sbin/initctl
    sed -i 's/^exit.*/exit 0/' /sbin/initctl
    
    echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
  
    echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean
    echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean
    echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean
    
    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages
    
    echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes
    
    echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
    [ -z "$(apt-get indextargets)" ]
    mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
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
