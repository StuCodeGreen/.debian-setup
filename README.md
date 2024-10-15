
# Setup and Restore Script

This script automates the setup and restoration of your Debian development environment, including configuration files, essential packages, and development tools.

## Features

- **Logging**: Provides informative and error logs during execution.
- **Backup Management**: Restores backups of configuration files and maintains version control.
- **Neovim Installation**: Installs Neovim and adds it to your system PATH.
- **NVM and Node.js Setup**: Installs NVM (Node Version Manager) and the latest LTS version of Node.js.
- **Oh My Zsh Installation**: Installs Oh My Zsh for enhanced Zsh shell experience.
- **Custom Configuration**: Sets up custom `.myProfile` and `.gitignore_global` files.

## Prerequisites

- A Debian-based operating system
- Zsh shell (will be installed by script)
- Basic knowledge of terminal commands

## Usage

1. **Clone the Repository** (if applicable):

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Make the Script Executable**:

   ```bash
   chmod +x setup-restore
   ```

3. **Run the Script**:

   ```bash
   ./setup-restore
   ```

   **Note**: Do not run this script as root or with sudo.

## Functionality Overview

- **Logging Functions**: Provides consistent logging for both informational and error messages.
- **Package Installation**: Installs essential packages such as `curl`, `git`, `zsh`, `ripgrep`, `xclip`, `xsel`, `tmux`, and `alacritty`.
- ~~**Backup Restoration**: If available restores backup files from `dotfiles_backup.tar.gz` and `dev_files_backup.tar.gz`.~~
- **File Management**: Compares and manages the setup of `.myProfile` and `.gitignore_global`, allowing options to overwrite, update, or do nothing based on file differences.
- **Configuration Setup**: Ensures that `.myProfile` is sourced in your `.zshrc` file.

## Conclusion

This script simplifies the process of setting up your development environment on Debian. It ensures that all necessary tools and configurations are in place, allowing you to focus on development.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
