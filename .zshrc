# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export VAULT_ADDR="https://vault.chu-brest.fr"

export PATH=/data/homes/arthur/.cargo/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="catppuccin"
CATPPUCCIN_FLAVOR="mocha" # Required! Options: mocha, flappe, macchiato, latte
CATPPUCCIN_SHOW_TIME=true  # Optional! If set to true, this will add the current time to the prompt.


ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,standout"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1
plugins=(
            git
            z
            ssh-agent
            uv
            zsh-autosuggestions
            zsh-syntax-highlighting
        )

source $ZSH/oh-my-zsh.sh


zshaddhistory() {
    local cmd_lower=${1:l}
    [[ $cmd_lower =~ (hvs|access.?id|secret.?id|password|vault_token|password|pwd) ]] && return 1
    return 0
}


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


#!/bin/bash

get_creds() {
    local service=""
    local role=""

    # Parsing des arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --minio)
                service="minio"
                role="$2"
                shift 2
                ;;
            --starrocks)
                service="starrocks"
                role="$2"
                shift 2
                ;;
            *)
                echo "Option inconnue: $1"
                echo "Usage: get_creds --minio <role> | --starrocks <role>"
                return 1
                ;;
        esac
    done

    if [[ -z "$service" || -z "$role" ]]; then
        echo "Usage: get_creds --minio <role> | --starrocks <role>"
        return 1
    fi

    # Commandes selon combinaison
    case "$service:$role" in
        minio:scientist)
            echo "Exécution commande pour MinIO scientist"
            vault read minio/keys/scientist
            ;;
        minio:scientist_pii)
            echo "Exécution commande pour MinIO scientist_pii"
            vault read minio/keys/scientist_pii
            ;;
        starrocks:scientist)
            echo "Exécution commande pour StarRocks scientist"
            vault read starrocks/creds/scientist
            ;;
        starrocks:scientist_pii)
            echo "Exécution commande pour StarRocks scientist_pii"
            vault read starrocks/creds/scientist_pii
            ;;
        *)
            echo "Combinaison service=$service et role=$role non reconnue."
            return 1
            ;;
    esac
}

