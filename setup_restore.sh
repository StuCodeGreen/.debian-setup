#!/bin/zsh

# Logging functions
log() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Ensure the script is not run as root
if [ "$EUID" -eq 0 ]; then
    log_error "Do not run this script as root or with sudo."
fi

# Define paths for backup and files
BACKUP_DIR=~/.debian-setup
MYPROFILE_PATH="$BACKUP_DIR/.myProfile"
GITIGNORE_GLOBAL_PATH="$BACKUP_DIR/.gitignore_global"
GLOBAL_GITIGNORE=~/.gitignore_global
ZSHRC_PATH=~/.zshrc

# Add Neovim to PATH in .zshrc if missing
add_nvim_to_path() {
    local nvim_path='export PATH="$PATH:/opt/nvim-linux64/bin"'
    if ! grep -v '^#' "$ZSHRC_PATH" | grep -q "$nvim_path"; then
        echo "$nvim_path" >> "$ZSHRC_PATH"
        log "Neovim path added to .zshrc. Please restart terminal to apply changes."
    else
        log "Neovim path already in .zshrc."
    fi
}

# Install packages if missing
install_if_missing() {
    if ! dpkg -l | grep -q "^ii  $1 "; then
        log "Installing $1..."
        sudo apt-get install -y "$1" || log_error "Failed to install $1."
    else
        log "$1 is already installed."
    fi
}

# Restore backup if exists
# NOTE: Not sure if this is useful
#restore_backup() {
#    local file=$1
#    local dest=$2

#    if [ -f "$file" ]; then
#        tar -xzvf "$file" -C "$dest" || log_error "Failed to restore $file."
#        log "Restored $file."
#    else
#        log "Backup $file not found. Skipping."
#    fi
#}

# Clone repo if not already cloned
clone_repo() {
    local repo_url=$1
    local dest_dir=$2

    if [ ! -d "$dest_dir" ]; then
        log "Cloning $repo_url into $dest_dir..."
        git clone "$repo_url" "$dest_dir" || log_error "Failed to clone repository."
    else
        log "Repository already exists at $dest_dir."
    fi
}

# Install Neovim
install_neovim() {
    if ! command -v nvim &> /dev/null; then
        log "Installing Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        sudo rm -rf /opt/nvim-linux64
        sudo tar -C /opt -xzf nvim-linux64.tar.gz
        rm nvim-linux64.tar.gz
        add_nvim_to_path
        command -v nvim &> /dev/null && log "Neovim installed successfully." || log_error "Neovim installation failed."
    else
        log "Neovim is already installed."
        add_nvim_to_path
    fi
}

# Install NVM and Node.js LTS
install_nvm() {
    if [ ! -d ~/.nvm ]; then
        log "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash || log_error "Failed to install NVM."
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts || log_error "Failed to install Node.js LTS."
    else
        log "NVM is already installed."
    fi
}

# Function to set up and manage files
manage_file() {
    local source_file=$1
    local dest_file=$2
    local description=$3
    local backup_file="${dest_file}.bak"

    if [ -f "$dest_file" ]; then
        log "$description exists."

        # Check if the content of the source file is different from the destination file
        if ! cmp -s "$source_file" "$dest_file"; then
            log "Content differs from backup. What do you want to do?"
            echo "1) Overwrite $description with remote content (creates a backup of the current file)"
            echo "2) Update remote file with current version of $description"
            echo "3) Do nothing"
            read -r choice

            case $choice in
                1)
                    # Create a backup of the current file before overwriting
                    log "Overwriting $description with remote version."
                    cp "$dest_file" "$backup_file" || log_error "Failed to create a backup."
                    cp "$source_file" "$dest_file" || log_error "Failed to overwrite $description."
                    log "Backup of the old $description saved as $backup_file."
                    ;;
                2)
                    log "Updating remote for $description."
                    cp "$dest_file" "$source_file" || log_error "Failed to update remote."
                    log "Remote updated with the current version of $description."
                    ;;
                3)
                    log "No changes made to $description."
                    ;;
                *)
                    log "Invalid choice. No changes made."
                    ;;
            esac
        else
            log "$description is already up to date."
        fi
    else
        log "Creating $description from backup."
        cp "$source_file" "$dest_file" || log_error "Failed to create $description."
    fi
}


# Function to set up global .gitignore
setup_gitignore_global() {
    manage_file "$GITIGNORE_GLOBAL_PATH" "$GLOBAL_GITIGNORE" ".gitignore_global"

    # Ensure Git configuration points to the global .gitignore
    if [ "$(git config --global core.excludesfile)" != "$GLOBAL_GITIGNORE" ]; then
        log "Setting Git global excludesfile to .gitignore_global."
        git config --global core.excludesfile "$GLOBAL_GITIGNORE"
    fi
}

# Function to set up .myProfile
setup_profile() {
    manage_file "$MYPROFILE_PATH" "$HOME/.myProfile" ".myProfile"

    # Ensure .myProfile is sourced in .zshrc
    if ! grep -q "source ~/.myProfile" "$ZSHRC_PATH"; then
        log "Adding source line to .zshrc."
        echo "source ~/.myProfile" >> "$ZSHRC_PATH"
    else
        log ".myProfile is already sourced in .zshrc."
    fi
}




# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d ~/.oh-my-zsh ]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || log_error "Failed to install Oh My Zsh."
        chsh -s "$(which zsh)" || log_error "Failed to set Zsh as the default shell."
    else
        log "Oh My Zsh is already installed."
    fi
}

# Install missing packages
packages=(curl git zsh ripgrep xclip xsel tmux rclone)
for package in "${packages[@]}"; do
    install_if_missing "$package"
done

# Restore backups
# NOTE: Not used currently
#restore_backup "dotfiles_backup.tar.gz" "$HOME"
#restore_backup "dev_files_backup.tar.gz" "$HOME"

# Install tools and configurations
install_oh_my_zsh
install_neovim
install_nvm

log "Setting up profiles and configurations..."
setup_profile
setup_gitignore_global

# Clone Neovim configuration repo
clone_repo "git@github.com:StuCodeGreen/nvim-setup.git" ~/.config/nvim

log "Script completed successfully."

