
.PHONY: all clean

all: tgt.bzl

tgt.bzl: 
		rm -f fifo_{r,w,ps}
		mkfifo fifo_{r,w}
		+cat <&3 >fifo_r & echo $$! >fifo_ps
		+( while true; do [ -e fifo_w ] || exit; cat <fifo_w; sleep 0.1; done ) >&4 & echo $$! >>fifo_ps
		bazel build --sandbox_debug --verbose_failures //ubuntu/libs:make_tool || :
		cat > fifo_w <<- ""
		kill $$(<fifo_ps)
		rm -f fifo_{r,w,ps}