#!/bin/sh
tmux new-session -d -s codserversd
tmux send-keys -t codserversd 'sudo su' ENTER
tmux send-keys -t codserversd 'cd /cod1/sd' ENTER
tmux send-keys -t codserversd './startmyserver.sh' ENTER
