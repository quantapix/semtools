# ubuntu

init() {
    key="D2EB44626FDDC30B513D5BB71A5D6C4C7DB87C81"
    export GNUPGHOME="$(mktemp -d)"
	  gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"
    
    for v in focal hirsute; do
        mkdir -p $v
        (cd $v
            url="https://partner-images.canonical.com/core/$v/current"
            base="ubuntu-$v-core-cloudimg-amd64"
            wget -qN "$url/"{{MD5,SHA{1,256}}SUMS{,.gpg},"$base.manifest",'unpacked/build-info.txt'}
            tar="$base-root.tar.gz"
            wget -N --progress=dot:giga "$url/$tar"
            for s in sha256 sha1 md5; do
                file="${s^^}SUMS"
                gpg --batch --verify "$file.gpg" "$file" || exit
                cmd="${s}sum"
                grep " *$tar\$" "$file" | "$cmd" -c - || exit
            done
        )
    done

    command -v gpgconf > /dev/null && gpgconf --kill all || :
    rm -rf "$GNUPGHOME"
}

run() {
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

clean() {
    rm -rf pkgs
}
