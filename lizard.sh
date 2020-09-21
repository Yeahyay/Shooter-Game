#!/usr/bin/env bash

PROGRAM_NAME=lizard

COMMAND="lizard ./src -x\"./lib/*\""
gnome-terminal -e "bash -c \"$COMMAND; exec bash\"" \
# &> /dev/null
# &> out.log
# echo NORMAL

wait $!

sleep 0.05

xdotool search --onlyvisible --classname "Gnome-terminal" windowfocus windowraise windowactivate

wait $!

echo "done"
