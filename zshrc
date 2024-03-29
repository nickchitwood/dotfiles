# Profile zsh startup
if [[ "$ZPROF" = true ]]; then
  zmodload zsh/zprof
fi

# Get current distro
if [[ $OSTYPE != darwin* ]]; then
	. /etc/os-release
	OS=$ID
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/o10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation. 
# Installed to user folder for RHEL, and MacOS. Arch installs to /usr/share
if [[ -v REMOTE_CONTAINERS_IPC || $OS == "rhel" || $OS == "fedora" ||  $OSTYPE == darwin* ]]; then
    ZSH=~/.oh-my-zsh
else
    ZSH=/usr/share/oh-my-zsh
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

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
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
	docker 
	git 
	npm
	vi-mode 
	yarn
	z 
	zsh-autosuggestions
	)

# User configuration

# Brew compleitions - zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit

fi


ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi


# Fedora Theme Conf
if [[ $OS == "fedora" ]]; then
	ZSH_THEME="powerlevel10k/powerlevel10k"
	[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# Oh my ZSh
source $ZSH/oh-my-zsh.sh

# Arch Conf
if [[ ( $OS == "arch" || $OS == "steamos" ) && ($TERM != "screen-256color") && ($TERM != "linux") ]]; then
	# Default apps
	export EDITOR=/usr/bin/nvim
	export VISUAL=/usr/bin/nvim
	export TERMINAL=/usr/bin/kitty
	export MANWIDTH=999
	export MANPAGER='nvim +Man!'

	# Powerlevel10k
	source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
	
	# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
	[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
	
	# Fix Ranger opening in XTerm
	export TERMCMD=/usr/bin/kitty
	

	# autoload -Uz compinit
	# compinit

	alias ssh='kitty +kitten ssh '
fi

# Enable asdf
if [[ $OS == arch ]]; then	
  . /opt/asdf-vm/asdf.sh
fi

# Mac OS Specific Config
if [[ $OSTYPE == darwin* ]]; then

	# Preferred editor for local and remote sessions
	if [[ -n $SSH_CONNECTION ]]; then
	  export EDITOR='nano'
	else
	  export EDITOR='nvim'
	fi

	# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
	[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

	# Fix brew path
	eval "$(/opt/homebrew/bin/brew shellenv)"
	
	# Powerlevel10k
	source $(brew --prefix powerlevel10k)/powerlevel10k.zsh-theme
	
	# Mac OS Specific plugins
	plugins+=(brew)

	# Load asdf
	. $(brew --prefix asdf)/libexec/asdf.sh

	# Set nativifier install path
	export NATIVEFIER_APPS_DIR=~/Applications/
	
	#  Pyenv
	export PYENV_ROOT="$HOME/.pyenv"
	command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"
	
	#NVM
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi


# Extended Globs
setopt extendedglob

# Aliases
source ~/.aliases

if [[ "$ZPROF" = true ]]; then
  zprof
fi

