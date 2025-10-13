# If you come from bash you might have to change your $PATH.
[<35;161;42M# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"


export PATH=/data/homes/arthur/.cargo/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell" # set by `omz`

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
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
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z ssh-agent uv)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

function new_uv_project() {
    if [ $# -lt 1 ]; then
        echo "Usage: new_uv_project <project_name> [python_version_or_path]"
        return 1
    fi

    local project_name=$1
    local python_input=${2:-}
    local python_path=""    

    # Si l'utilisateur donne "3.10", on essaie de trouver le binaire
    if [ -n "$pythoninput" ]; then
        if [[ "$python_input" =~ ^[0-9]+\.[0-9]+$ ]]; then
            python_path=$(command -v python$python_input)
            if [ -z "$python_path" ]; then
                echo "❌ Python version python$python_input not found in PATH"
                return 1
            fi
        else
            python_path=$python_input
        fi
    else
        # Python par défaut
        python_path=$(command -v python3)
    fi

    uv init "$project_name"
    cd "$project_name" || return
    uv venv --python "$python_path"
    source .venv/bin/activate

    echo "Projet '$project_name' créé avec Python '$python_path' et environnement activé !"
}

function install_pyproject_dependencies() {
    if [ ! -f pyproject.toml ]; then
        echo "❌ Aucun fichier pyproject.toml trouvé dans le dossier courant."
        return 1
    fi

    python_version=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    
    if (( $(echo "$python_version >= 3.11" | bc -l) )); then
        echo "✅ Python $python_version : utilisation de tomllib"
        python -m pip install $(
            python -c '
import tomllib
with open("pyproject.toml", "rb") as f:
    deps = tomllib.load(f)["project"]["dependencies"]
print(" ".join(deps))
'
        )
    else
        echo "⚠️ Python $python_version : fallback parsing (sans tomllib)"
        cat pyproject.toml \
        | grep dependencies -A1000 \
        | tr -d '\n' \
        | cut -d '[' -f 2 \
        | cut -d ']' -f 1 \
        | sed 's/"\([^"]*\)",\s*/\1 /g' \
        | xargs pip install -U
    fi
}

<<<<<<< HEAD
alias g=git
=======
<<<<<<< HEAD

<<<<<<< HEAD
=======
#!/bin/bash

alias g=git
alias v=vault
>>>>>>> f48ea50 (new zshrc)
=======
alias g=git
>>>>>>> 9a2c8bc (new zshrc)
>>>>>>> 9cdab6f (new zshrc)
