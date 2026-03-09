# Modular Zsh Configuration

This directory contains a modular, organized approach to zsh configuration. Instead of having one monolithic `.zshrc` file, the configuration is split into focused, single-purpose files that are loaded in a specific order.

## Structure

```
~/.zsh/
├── 00-env.zsh              # Environment variables & PATH
├── 10-history.zsh          # History configuration
├── 20-oh-my-zsh.zsh        # Oh-My-Zsh framework setup
├── 30-editor.zsh           # Editor configuration (neovim, nvr)
├── 40-languages.zsh        # Language environments (Node, Go, Ruby, etc.)
├── 50-tools.zsh            # Development tools & completions
├── 60-aliases.zsh          # General shell aliases
├── 70-functions.zsh        # Utility functions
├── 80-tmux-sessions.zsh    # Tmux/Azure/GitHub session management
└── 90-archived.zsh         # Archived/commented code for reference
```

## Load Order

Files are numbered with prefixes to control load order:

1. **00-** Environment setup (must load first)
2. **10-** History configuration
3. **20-** Oh-My-Zsh initialization
4. **30-** Editor configuration
5. **40-** Language environments (Node, Go, Ruby, Java, etc.)
6. **50-** Development tools (Docker, kubectl, OpenCode, etc.)
7. **60-** Aliases
8. **70-** Functions
9. **80-** Session management (tmux, Azure, GitHub context switching)
10. **90-** Archived code (reference only)

## File Descriptions

### 00-env.zsh
Core environment variables and PATH configuration. Sets up:
- Local bin directories
- Homebrew paths (platform-aware)
- Ruby gems, Go, Rust, Deno paths
- Password store location
- Platform-specific compiler flags

### 10-history.zsh
Shell history settings:
- Unlimited history size
- Immediate history append
- Duplicate handling
- Timestamp format

### 20-oh-my-zsh.zsh
Oh-My-Zsh framework configuration:
- Theme selection (bira)
- Plugin loading (git, node, terraform, tmux, kubectl)
- Framework initialization

### 30-editor.zsh
Editor preferences and locale:
- VISUAL/EDITOR setup (neovim/neovim-remote)
- LC_ALL, LC_CTYPE settings
- SSH key path
- Compilation flags

### 40-languages.zsh
Programming language version managers and SDKs:
- Node.js (NVM)
- pnpm
- Bun
- Deno
- Android SDK
- Java (SDKMAN) - loaded last per SDKMAN requirements

### 50-tools.zsh
Development tools, aliases, and completions:
- Docker Compose aliases
- Spring Boot aliases
- Avante (AI Neovim) alias
- Azure CLI completion
- thefuck integration
- OpenCode experimental features
- Antigravity
- envman

### 60-aliases.zsh
General purpose aliases:
- File operations (trash)
- Git (glg)
- Editor (vim → nvim)
- Suffix aliases (open files by extension)
- Shell config shortcuts (ec, sc)
- Network utilities (localip)

### 70-functions.zsh
Utility functions:
- `portcheck()` - Check if a port is in use
- `ggupdate()` - Git update workflow
- `aks-refresh-creds()` - Refresh Azure Kubernetes credentials
- `aks-ensure-creds()` - Ensure AKS credentials exist

### 80-tmux-sessions.zsh
Comprehensive tmux session and context management:
- Azure environment switching (azure-sj, azure-softcode, azure-imonir)
- GitHub account switching (github-sj, github-softcode, github-imonir)
- Combined session management (session-sj, session-softcode, session-imonir)
- Automatic detection based on tmux session name
- Safety wrappers for az, kubectl, gh commands
- GitHub Copilot and OpenCode config switching
- Project-specific aliases and secrets

### 90-archived.zsh
Commented and unused code kept for reference:
- Oh-My-Zsh optional settings
- Alternative locale configurations
- Archived Android development settings
- Unused pyenv configuration
- Compiler flags for libraries
- Alternative PATH management methods

## Variables

The configuration uses these variables for portability:

- `$DOTFILES_OS` - Operating system (Darwin/Linux)
- `$DOTFILES_BREW_PREFIX` - Homebrew installation prefix
- `$DOTFILES_HOME` - User home directory

## Machine-Specific Overrides

Create `~/.zshrc.local` for machine-specific settings that shouldn't be tracked in git. This file is sourced last and can override any settings.

## Symlinking

The main `~/.zshrc` file should be symlinked from this repository:

```bash
ln -s ~/work/utils/dotfiles/.zshrc ~/.zshrc
```

The loader automatically sources all `*.zsh` files from `~/.zsh/` directory.

## Adding New Configuration

To add new configuration:

1. Choose the appropriate file based on the configuration's purpose
2. Add the configuration to that file with appropriate comments
3. If it's a new category, create a new numbered file (e.g., `45-new-category.zsh`)
4. The loader will automatically pick up any `.zsh` files in this directory

## Debugging

To debug configuration loading:

1. Comment out files in the loader to isolate issues
2. Use `zsh -x` to trace execution
3. Check specific files with `source ~/.zsh/XX-filename.zsh`

## Performance

Shell startup performance can be measured with:

```bash
time zsh -i -c exit
```

If slow, profile with:

```bash
zsh -xv
```

## Maintenance

- Keep related settings together in the same file
- Add comments explaining non-obvious configurations
- Archive unused code in `90-archived.zsh` rather than deleting
- Update this README when adding new files or significant changes
