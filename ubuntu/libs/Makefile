
.PHONY: all clean

all: tgt.bzl

tgt.bzl: 
		mkfifo fifo_{r,w}
		+cat <&3 >fifo_r & echo $$! >pids
		( while true; do [ -e fifo_w ] || exit; cat <fifo_w; sleep 0.1; done ) >&4 & echo $$! >>pids
		bazel build //ubuntu/libs:libz
		cat > fifo_w <<- ""
		kill $$(<pids)
		rm -f fifo_{r,w} pids