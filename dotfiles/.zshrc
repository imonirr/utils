# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="bira"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

export HISTFILE=~/.zsh_history
export HISTFILESIZE=999999999
export HISTSIZE=999999999
# # Immediate append Setting the inc_append_history option ensures that commands
# are added to the history immediately (otherwise, this would happen only when
# the shell exits, and you could lose history upon unexpected/unclean
# termination of the shell).
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
# Handling duplicate commands (While searching with Ctrl+R)
setopt HIST_FIND_NO_DUPS

#  not writing duplicates to the history file
setopt HIST_IGNORE_ALL_DUPS



# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git node terraform)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
# export LANG_ALL=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# export LANG=en_US.iso88591
# export LC_MESSAGES="C"


# Preferred editor for local and remote sessions
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
    export VISUAL="nvim"
    export EDITOR="nvim"
fi


# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/id_ed25519"

export PATH="${PATH}:$HOME/.local/bin"

export hostname=$HOST

# react-native android development
export ANDROID_SDK=$HOME/Android/Sdk
# export ANDROID_HOME=$HOME/Android/Sdk
# export PATH=$PATH:$ANDROID_HOME/tools
# export PATH=$PATH:$ANDROID_HOME/platform-tools
# # android virtual device
# export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias trash='mv -t /tmp'
alias glg="git log --color --all --date-order --decorate --dirstat=lines,cumulative --stat | sed 's/\([0-9] file[s]\? .*)$\)/\1\n_______\n-------/g' | \less -R"

alias dup='docker-compose up'
alias ddown='docker-compose down'
alias dbuild='docker-compose build'


alias sboot='mvn spring-boot:run'
alias sbootc='mvn clean compile && mvn spring-boot:run'

# Set up Node Version Manager


export PATH="${PATH}:/opt"
export PATH="${PATH}:/home/monir/.dropbox-dist"

# ibus avro
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# Open file with program
alias -s md=vim
alias -s json=vim
alias -s {css,ts,html}=vim
alias -s {mp4}=vlc

# open ~/.zshrc in using the default editor specified in $EDITOR
alias ec="$EDITOR $HOME/.zshrc"
# source ~/.zshrc
alias sc="source $HOME/.zshrc"



# functions
portcheck() {
    sudo nc localhost $1 < /dev/null; echo $?
}

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

# autocompletion for kubectl
# source <(kubectl completion zsh)


# You can add the current Terraform workspace in your prompt by adding $(tf_prompt_info) to your PROMPT or RPROMPT variable.
# RPROMPT='$(tf_prompt_info)'

# deno
# export DENO_INSTALL="/home/$USER/.deno"
# export PATH="$DENO_INSTALL/bin:$PATH"


## python pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init --path)"
# eval "$(pyenv init -)"

# # Load pyenv-virtualenv automatically by adding
# eval "$(pyenv virtualenv-init -)"

# alias python=python3
# export PATH="${PATH}:$HOME/Library/Python/3.9/bin"




# https://apple.stackexchange.com/questions/20547/how-do-i-find-my-ip-address-from-the-command-line
alias localip='dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com'


# go package installation
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# What OS are we running?


if [[ `uname` == "Darwin" ]]; then
    echo 'OSX!'

    export JAVA_HOME="/Users/monir/.sdkman/candidates/java/current/bin/java"

    # # For compilers to find sqlite you may need to set:
    # export LDFLAGS="-L/opt/homebrew/opt/sqlite/lib"
    # export CPPFLAGS="-I/opt/homebrew/opt/sqlite/include"
    # # For pkg-config to find sqlite you may need to set:
    # export PKG_CONFIG_PATH="/opt/homebrew/opt/sqlite/lib/pkgconfig"
    #
    # # For compilers to find zlib you may need to set:
    # export LDFLAGS="-L/opt/homebrew/opt/zlib/lib"
    # export CPPFLAGS="-I/opt/homebrew/opt/zlib/include"
    # # For pkg-config to find zlib you may need to set:
    # export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig"



    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

    export PATH="$HOME/.deno/bin:$PATH"

    # bun completions
    [ -s "/Users/moniruzzamanmonir/.bun/_bun" ] && source "/Users/moniruzzamanmonir/.bun/_bun"

    # bun
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    # autocompletion from thefuck
    eval $(thefuck --alias)
    export PATH="$HOME/.deno/bin:$PATH"

    # Generated for envman. Do not edit.
    [ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/Users/monir/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/monir/google-cloud-sdk/path.zsh.inc'; fi

    # The next line enables shell command completion for gcloud.
    if [ -f '/Users/monir/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/monir/google-cloud-sdk/completion.zsh.inc'; fi
    if test -f "/Users/monir/work/sj/Medvind-Tools/gustav.sh"; then; alias gustav="/Users/monir/work/sj/Medvind-Tools/gustav.sh"; fi
    export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
    if test -f "/Users/monir/work/sj/Medvind-Tools/.env.secrets"; then; export $(cat "/Users/monir/work/sj/Medvind-Tools/.env.secrets" | xargs); fi
    if test -f "/Users/monir/work/sj/.env.secrets"; then; export $(cat "/Users/monir/work/sj/.env.secrets" | xargs); fi


    export PATH=$(npm bin -g):$PATH
    # case ":$PATH:" in
    #   *":/Users/monir/bin:"*) ;;
    #   *) export PATH="$PATH:/Users/monir/bin" ;;
    # esac
    export PATH=$HOME/bin:$PATH
    # bit end
    #
    # rust compiler from https://rustup.rs/
    export PATH=$HOME/.cargo/bin:$PATH


# elif command apt > /dev/null; then
    # echo 'Debian!'



else
    echo 'Unknown OS!'

    alias peanut='nmcli d wifi connect "Mr. Peanutbutter"'

    # change brightness
    alias lowlight="echo 30000 | sudo tee /sys/class/backlight/intel_backlight/brightness"
    alias midlight="echo 70000 | sudo tee /sys/class/backlight/intel_backlight/brightness"
    alias highlight="echo 120000 | sudo tee /sys/class/backlight/intel_backlight/brightness"
    # alias lowlight="echo 40 | sudo tee /sys/class/backlight/amdgpu_bl0/brightness"
    # alias midlight="echo 100 | sudo tee /sys/class/backlight/amdgpu_bl0/brightness"
    # alias highlight="echo 200 | sudo tee /sys/class/backlight/amdgpu_bl0/brightness"

    # check battery percentage LINUX
    alias battery="upower -i `upower -e | grep 'BAT'` | grep percentage"

    # rsync copy with progress
    alias copy="rsync -ah --progress"


    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    export PATH="$PATH:/opt/nvim-linux64/bin"

    M2_HOME='/opt/apache-maven-3.9.9'
    PATH="$M2_HOME/bin:$PATH"
    export PATH
fi


function az_work {
    export AZURE_CONFIG_DIR=~/.Azure-SJ
    az login --use-device-code
}
 
function az_personal {
    export AZURE_CONFIG_DIR=~/.Azure-Personal
    az login --use-device-code
}


    #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
