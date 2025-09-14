#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$({ find ~/ ~/Programs/video-peel ~/.config ~/Programs ~/Programs/bridge ~/Exercism/ ~/csprimer -mindepth 1 -maxdepth 1 -type d; } | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

# Check for pinned worktree - read from repo file
pins_file="$HOME/.config/home-manager/home/tmux-worktree-pins"
selected_name=$(basename "$selected" | tr . _)

if [[ -f "$pins_file" ]]; then
    # Only apply pin logic to exact repo names or simple suffixes
    # Don't redirect worktrees with specific branch names
    base_repo_name="$selected_name"
    
    # Only strip simple suffixes, not full branch names
    if [[ "$selected_name" =~ ^(.+)-(main|current|dev)$ ]]; then
        base_repo_name="${BASH_REMATCH[1]}"
    fi
    
    # Only redirect if it's the exact base repo name, not specific worktrees
    if [[ "$base_repo_name" == "$selected_name" ]]; then
        pinned_path=$(grep "^${base_repo_name}:" "$pins_file" 2>/dev/null | cut -d: -f2-)
        
        if [[ -n "$pinned_path" && -d "$pinned_path" ]]; then
            selected="$pinned_path"
            # Keep the actual worktree name for the session, not the base repo name
            selected_name=$(basename "$pinned_path" | tr . _)
        fi
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
