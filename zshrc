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

# --- Powerlevel10k Instant Prompt ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

# Fedora: set p10k theme before oh-my-zsh source
if [[ $OS == "fedora" || $OS == "ubuntu" || $OS == "debian" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
fi

source $ZSH/oh-my-zsh.sh

# --- Shared Config ---
setopt extendedglob
export PATH="$HOME/.local/bin:$PATH"
source ~/.aliases

# --- OS: Arch / SteamOS ---
if [[ ($OS == "arch" || $OS == "steamos") && $TERM != "screen-256color" && $TERM != "linux" ]]; then
  export EDITOR=/usr/bin/nvim
  export VISUAL=/usr/bin/nvim
  export TERMINAL=/usr/bin/kitty
  export TERMCMD=/usr/bin/kitty
  export MANWIDTH=999
  export MANPAGER='nvim +Man!'

  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
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
  source $(brew --prefix powerlevel10k)/share/powerlevel10k/powerlevel10k.zsh-theme

  # Brew completions
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit

  . $(brew --prefix asdf)/libexec/asdf.sh

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# --- Powerlevel10k Config ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Device Config ---
[[ -f ~/.zshrc.d/${HOST%%.*}.zsh ]] && source ~/.zshrc.d/${HOST%%.*}.zsh

# --- Profiling ---
if [[ "$ZPROF" = true ]]; then
  zprof
fi
