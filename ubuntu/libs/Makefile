

#!/bin/bash
set -euo pipefail
JOBSERVER=${JOBSERVER:-$HOME/.jobserver}
NPROC=${1:-$(nproc)}
mkdir -p $JOBSERVER
rm -f $JOBSERVER/rd $JOBSERVER/wr
mkfifo $JOBSERVER/rd $JOBSERVER/wr
echo "jobserver: ; +cat >$JOBSERVER/rd <&3 & ( while true; do cat <$JOBSERVER/wr; sleep 0.1; done ) >&4 & wait" | make -f - -j $NPROC jobserver


#!/bin/bash
set -euo pipefail
MAKE=${MAKE:-make}
exec 3<$JOBSERVER/rd
exec 4>$JOBSERVER/wr
MAKEFLAGS=" -j --jobserver-fds=3,4" ${MAKE} "$@"