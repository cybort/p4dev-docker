#!/bin/bash
set -euo pipefail
install_from_tar_or_git() {
    local tar_path=$1
    local git_url=$2
    local target_dir=$3
    
    if [ -e "$target_dir" ]; then
        echo "[INFO] Removing existing directory: $target_dir"
        rm -rf "$target_dir"
    fi
    
    if [ -f "$tar_path" ]; then
        echo "[INFO] Archive found, extracting: $tar_path -> $target_dir..."
        local temp_dir
        temp_dir=$(mktemp -d)
        tar -xaf "tar_path" -C "$temp_dir"
        mkdir "target_dir"
        mv "temp_dir"/* "target_dir"
        rm -rf "$temp_dir"
    else
        echo "[INFO] Cloning repo: $git_url -> $target_dir"
        git clone "$git_url" "$target_dir"
    fi
    
    echo "[DEBUG] Target directory: $target_dir"
    echo "[DEBUG] Directory exists? $( [ -d "$target_dir" ] && echo "Yes" || echo "No" )"
    echo "[DEBUG] Directory contents:"
    ls -la "$target_dir" 2>/dev/null || echo "[ERROR] Cannot read directory"
    echo "[DEBUG] Is directory empty? $( [ -z "$(ls -A "$target_dir" 2>/dev/null)" ] && echo "Yes" || echo "No" )"
    echo "[DEBUG] Is directory a git repo? $( git -C "$target_dir" rev-parse --is-inside-work-tree 2>/dev/null || echo "No" )"
}

install_from_tar_or_git "$1" "$2" "$3"
