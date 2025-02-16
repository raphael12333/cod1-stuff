#!/bin/sh
tmux new-session -d -s codserver
tmux send-keys -t codserver 'sudo su' ENTER
tmux send-keys -t codserver 'cd /data/myserver' ENTER
tmux send-keys -t codserver './startmyserver.sh' ENTER