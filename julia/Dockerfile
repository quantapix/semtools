ARG VERSION=1.5.3
FROM qbrn.reg/ubu-run:std

ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH

ENV JULIA_VERSION ${VERSION}
ENV JULIA_GPG 3673DF529D9049477F76B37566E3C7DC03D6E495

RUN set -eux; \
	aptMark="$(apt-mark showmanual)"; \
 	if ! command -v gpg > /dev/null; then \
 		apt-get update; \
 		apt-get install -y --no-install-recommends \
 			gnupg \
 			dirmngr \
 		; \
 		rm -rf /var/lib/apt/lists/*; \
 	fi; \
	\
	tarArch='x86_64'; dirArch='x64'; sha256='f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1' ;; \
	\
	folder="$(echo "$JULIA_VERSION" | cut -d. -f1-2)"; \
	curl -fL -o julia.tar.gz.asc "https://julialang-s3.julialang.org/bin/linux/${dirArch}/${folder}/julia-${JULIA_VERSION}-linux-${tarArch}.tar.gz.asc"; \
	curl -fL -o julia.tar.gz     "https://julialang-s3.julialang.org/bin/linux/${dirArch}/${folder}/julia-${JULIA_VERSION}-linux-${tarArch}.tar.gz"; \
	\
	echo "${sha256} *julia.tar.gz" | sha256sum -c -; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$JULIA_GPG"; \
	gpg --batch --verify julia.tar.gz.asc julia.tar.gz; \
	command -v gpgconf > /dev/null && gpgconf --kill all; \
	rm -rf "$GNUPGHOME" julia.tar.gz.asc; \
	\
	mkdir "$JULIA_PATH"; \
	tar -xzf julia.tar.gz -C "$JULIA_PATH" --strip-components 1; \
	rm julia.tar.gz; \
  \
 	apt-mark auto '.*' > /dev/null; \
	[ -z "$aptMark" ] || apt-mark manual $aptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	julia --version

CMD ["julia"]