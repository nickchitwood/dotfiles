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

# --- Cache dir ---
ZSH_CACHE_DIR=$HOME/.cache/zsh
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR

# --- History ---
HISTFILE=$ZSH_CACHE_DIR/history
HISTSIZE=10000
SAVEHIST=10000
setopt extended_history hist_ignore_dups hist_ignore_space
setopt inc_append_history share_history

# --- Shell options ---
setopt extendedglob auto_cd auto_pushd pushd_ignore_dups interactive_comments

# --- Vi mode ---
bindkey -v
export KEYTIMEOUT=1

# --- Shared ---
export PATH="$HOME/.local/bin:$PATH"
source ~/.aliases

# --- OS: macOS ---
# Requires (brew bundle): fnm, fzf, starship, zoxide, zsh-autosuggestions, zsh-syntax-highlighting
if [[ $OS == "darwin" ]]; then
  if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nano'
  else
    export EDITOR='nvim'
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Completions
  FPATH=$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit -d $ZSH_CACHE_DIR/zcompdump

  # Plugins — zsh-syntax-highlighting must be sourced last
  source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh
  source $HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh
  eval "$(zoxide init zsh)"
  eval "$(fnm env --use-on-cd)"
  source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

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

# --- OS: Ubuntu / Debian ---
if [[ $OS == "ubuntu" || $OS == "debian" ]]; then
  export EDITOR='nvim'
  export VISUAL='nvim'
fi

# --- Starship Prompt ---
eval "$(starship init zsh)"

# --- Device Config ---
[[ -f ~/.zshrc.d/${HOST%%.*}.zsh ]] && source ~/.zshrc.d/${HOST%%.*}.zsh

# --- Profiling ---
if [[ "$ZPROF" = true ]]; then
  zprof
fi
