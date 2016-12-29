#!/usr/bin/env bash

# the name of your primary tmux session
SESSION=$USER

# if the session is already running, just attach to it.
tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
    echo "Session $SESSION already exists. Attaching."
    sleep 1
    tmux -2 attach -t $SESSION
    exit 0;
fi

# create a new session, named $SESSION, and detach from it
tmux new-session -d -s $SESSION

# populate the windows you want
tmux new-window -t $SESSION:9 -n 'quickref' 'nvim ~/dev/dotfiles/quickref;bash -i'

# all done. select starting window and get to work
# you may need to cycle through windows and type in passwords
# if you don't use ssh keys
tmux select-window -t $SESSION:1
tmux -2 attach -t $SESSION
