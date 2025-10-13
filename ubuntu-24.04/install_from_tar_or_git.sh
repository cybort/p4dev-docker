#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "用法: $0 <archive_name> <git_url> <dest_dir>"
    exit 1
fi

ARCHIVE="$1"
GIT_URL="$2"
TARGET_DIR="$3"

if [ -d "$TARGET_DIR" ]; then
    exit 1
fi

if [ -f "$ARCHIVE" ]; then
    mkdir "$TARGET_DIR"
    case "$ARCHIVE" in
        *.tar.gz|*.tgz) tar -xzf "$ARCHIVE" -C "$TARGET_DIR" --strip-components=1 ;;
        *.tar.bz2) tar -xjf "$ARCHIVE" -C "$TARGET_DIR" --strip-components=1 ;;
        *.zip) unzip "$ARCHIVE" -d "$TARGET_DIR" ;;
        *) echo "$ARCHIVE not supported" && exit 1 ;;
    esac
else
    git clone "$GIT_URL" "$TARGET_DIR"
fi


