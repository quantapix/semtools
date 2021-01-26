#!/bin/bash
set -ex
# shellcheck source=/dev/null
source "$KOKORO_GFILE_DIR/common.sh"
sudo chmod +x "$KOKORO_GFILE_DIR/verify-commits.sh"

# Grab the latest version of shellcheck and add it to PATH
sudo cp "$KOKORO_GFILE_DIR"/shellcheck-latest.linux /usr/local/bin/shellcheck
sudo chmod +x /usr/local/bin/shellcheck

pushd github/debian-docker
# This is what travis currently does. Let's test what's faster.
make test
popd

"$KOKORO_GFILE_DIR"/verify-commits.sh
