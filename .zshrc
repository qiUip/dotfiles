export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="simple"

zstyle ':omz:update' frequency 5

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd/mm/yyyy"
setopt  HIST_IGNORE_ALL_DUPS

plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-vi-mode)
autoload -U compinit && compinit
_comp_options+=(globaldots);

# Load oh-my-zsh:
source $ZSH/oh-my-zsh.sh

# Aliases:
source $HOME/.config/aliases/command_aliases.sh
source $HOME/.config/aliases/api_keys

# Functions:
source $HOME/.scripts/fzf_bat.sh
source $HOME/.scripts/update-distro.sh

# Exports:
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.cabal/bin:$PATH"
export PATH="$HOME/.go/bin:$PATH"
export PATH="$HOME/.config/emacs/bin:$PATH"
source $HOME/.config/aliases/exports.sh
