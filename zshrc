# --- Profiling ---
if [[ "$ZPROF" = true ]]; then
  zmodload zsh/zprof
fi

# --- OS Detection ---
if [[ $OSTYPE == darwin* ]]; then
  OS=darwin
else
  . /etc/os-release
  OS=$ID
fi

# --- Oh-My-Zsh Setup ---
if [[ -v REMOTE_CONTAINERS_IPC || $OS == "rhel" || $OS == "fedora" || $OS == "ubuntu" || $OS == "debian" || $OS == "darwin" ]]; then
  ZSH=~/.oh-my-zsh
else
  ZSH=/usr/share/oh-my-zsh
fi

ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(
  brew
  docker
  git
  npm
  vi-mode
  yarn
  z
  zsh-autosuggestions
)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

# --- Shared Config ---
setopt extendedglob
export PATH="$HOME/.local/bin:$PATH"
source ~/.aliases

# --- Starship Prompt ---
eval "$(starship init zsh)"

# --- OS: Arch / SteamOS ---
if [[ ($OS == "arch" || $OS == "steamos") && $TERM != "screen-256color" && $TERM != "linux" ]]; then
  export EDITOR=/usr/bin/nvim
  export VISUAL=/usr/bin/nvim
  export TERMINAL=/usr/bin/kitty
  export TERMCMD=/usr/bin/kitty
  export MANWIDTH=999
  export MANPAGER='nvim +Man!'

  alias ssh='kitty +kitten ssh '
fi

if [[ $OS == "arch" ]]; then
  . /opt/asdf-vm/asdf.sh
fi

# --- OS: Ubuntu / Debian ---
if [[ $OS == "ubuntu" || $OS == "debian" ]]; then
  export EDITOR='nvim'
  export VISUAL='nvim'
fi

# --- OS: macOS ---
if [[ $OS == "darwin" ]]; then
  if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nano'
  else
    export EDITOR='nvim'
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Brew completions
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit

  . $(brew --prefix asdf)/libexec/asdf.sh

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# --- Device Config ---
[[ -f ~/.zshrc.d/${HOST%%.*}.zsh ]] && source ~/.zshrc.d/${HOST%%.*}.zsh

# --- Profiling ---
if [[ "$ZPROF" = true ]]; then
  zprof
fi
