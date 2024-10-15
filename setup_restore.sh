#!/bin/zsh

# Function for logging
log() {
    echo "[INFO] $1"
}

# Function for logging errors
log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Ensure script is not run as root
if [ "$EUID" -eq 0 ]; then
    log_error "This script cannot be run as root or with sudo. Please rerun the script without sudo."
fi

# Function to add Neovim to PATH in .zshrc
add_nvim_to_path() {
    if ! grep -v '^#' ~/.zshrc | grep -q 'export PATH="\$PATH:/opt/nvim-linux64/bin"'; then
        echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.zshrc
        log "Added Neovim to PATH in .zshrc. Please restart terminal to apply changes."
        source ~/.zshrc
    else
        log "Neovim path is already present .zshrc"
        source ~/.zshrc
    fi
}

# Function to install Neovim if not installed
install_neovim() {
    if ! command -v nvim &> /dev/null; then
        log "Neovim is not installed. Installing Neovim..."
        
        # Download Neovim package
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        
        # Remove any existing Neovim installation
        if [ -d $(which nvim) ]; then
            log "Removing existing Neovim installation..."
            sudo rm -rf $(which nvim)    
        fi
        
        # Extract and install Neovim
        sudo tar -C /opt -xzf nvim-linux64.tar.gz
        
        # Clean up downloaded file
        rm nvim-linux64.tar.gz
        
        # Add Neovim to PATH
        add_nvim_to_path
        
        # Verify installation
        if command -v nvim &> /dev/null; then
            log "Neovim installed successfully. Restart your terminal to apply the changes."
        else
            log_error "Neovim installation failed."
        fi
    else
        log "Neovim is already installed."
        
        # Ensure Neovim is in the PATH
        add_nvim_to_path
    fi
}

# Check and install package if missing
install_if_missing() {
    if ! dpkg -l | grep -q "^ii  $1 "; then
        log "$1 is not installed. Installing $1..."
        sudo apt-get install -y "$1" || log_error "Failed to install $1"
    else
        log "$1 is already installed."
    fi
}

# Restore dotfiles or development files
restore_backup() {
    local file=$1
    local dest=$2

    if [ -f ~/"$file" ]; then
        tar -xzvf ~/"$file" -C ~ || log_error "Failed to restore $file"
        log "$file restored successfully."
    else
        log "Backup $file not found. Skipping restoration."
    fi
}

# Clone a repository if it doesn't exist
clone_repo() {
    local repo_url=$1
    local dest_dir=$2

    if [ ! -d "$dest_dir" ]; then
        log "Cloning repository..."
        git clone "$repo_url" "$dest_dir" || log_error "Failed to clone repository."
    else
        log "Repository already exists at $dest_dir. Skipping clone."
    fi
}

# Install Oh My Zsh if not installed
install_oh_my_zsh() {
    if [ ! -d ~/.oh-my-zsh ]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || log_error "Failed to install Oh My Zsh."
        chsh -s "$(which zsh)" || log_error "Failed to set Zsh as default shell."
    else
        log "Oh My Zsh is already installed."
    fi
}

# Install Neovim if not installed
install_neovim() {
    if ! command -v nvim &> /dev/null; then
        log "Installing Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        sudo rm -rf /opt/nvim-linux64
        sudo tar -C /opt -xzf nvim-linux64.tar.gz
        add_nvim_to_path
        rm nvim-linux64.tar.gz
        if command -v nvim &> /dev/null; then
            log "Neovim installed successfully. Restart your terminal to apply changes."
        else
            log_error "Neovim installation failed."
        fi
    else
        log "Neovim is already installed."
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

# List of APT packages to install
packages=(curl git git-man zsh ripgrep xclip xsel tmux alacritty)

# Install missing packages
for package in "${packages[@]}"; do
    install_if_missing "$package"
done

# Restore backups
restore_backup "dotfiles_backup.tar.gz" "$HOME"
restore_backup "dev_files_backup.tar.gz" "$HOME"

# Install Oh My Zsh
install_oh_my_zsh

# Install Neovim
install_neovim

# Clone nvim setup
clone_repo "git@github.com:StuCodeGreen/nvim-setup.git" ~/.config/nvim

# Install NVM and Node.js LTS
install_nvm

log "Script execution completed successfully."
