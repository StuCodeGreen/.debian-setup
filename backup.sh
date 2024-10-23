#!/bin/zsh

# Define source directories
SOURCE_DIRS=("$HOME/Documents" "$HOME/Music" "$HOME/Pictures")

# Define the remote destination
REMOTE_DEST="stucodegreen-onedrive:debian-t450s"

# Loop through source directories and back them up
for DIR in "${SOURCE_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Backing up $DIR to $REMOTE_DEST"
        rclone sync "$DIR" "$REMOTE_DEST/$(basename "$DIR")" --progress
    else
        echo "Directory $DIR does not exist. Skipping."
    fi
done

echo "Backup completed."

