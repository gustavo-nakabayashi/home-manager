#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$({ find ~/ ~/Programs/video-peel ~/.config ~/Programs ~/Programs/bridge ~/csprimer -mindepth 1 -maxdepth 1 -type d; } | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

# Check for pinned worktree
pins_file="$HOME/.config/tmux-worktree-pins"
selected_name=$(basename "$selected" | tr . _)

if [[ -f "$pins_file" ]]; then
    # Remove common worktree suffixes to get base repo name
    base_repo_name=$(echo "$selected_name" | sed -E 's/-(main|current|dev|feature.*|fix.*|hotfix.*)$//')
    
    # Check if there's a pin for this repo
    pinned_path=$(grep "^${base_repo_name}:" "$pins_file" 2>/dev/null | cut -d: -f2-)
    
    if [[ -n "$pinned_path" && -d "$pinned_path" ]]; then
        selected="$pinned_path"
        selected_name="$base_repo_name"
    fi
fi
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