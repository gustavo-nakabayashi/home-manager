#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$({ find ~/ ~/Programs/video-peel ~/.config ~/Programs ~/Programs/bridge ~/csprimer -mindepth 1 -maxdepth 1 -type d; } | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

tmuxinator_config="$HOME/.config/tmuxinator/${selected_name}.yml"
if [[ ! -f "$tmuxinator_config" ]]; then
    tmuxinator_config="$HOME/.tmuxinator/${selected_name}.yml"
fi

if [[ -f "$tmuxinator_config" ]]; then
    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmuxinator start $selected_name
        exit 0
    fi
    
    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmuxinator start $selected_name
    fi
    
    tmux switch-client -t $selected_name
else
    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s $selected_name -c $selected
        exit 0
    fi

    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmux new-session -ds $selected_name -c $selected
    fi

    tmux switch-client -t $selected_name
fi