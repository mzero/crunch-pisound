#!/bin/sh
( stdbuf -o0 -e0 "$@" 2>&1 | grep --line-buffered -i xrun | xargs -I nope touch /tmp/xrun ) &
PID=$!
cat >/dev/null  # wait for stdin to close
kill $PID
