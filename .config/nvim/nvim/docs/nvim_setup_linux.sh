#!/bin/bash
set -exu
set -o pipefail

# Instalar paru si no está instalado
if ! command -v paru &> /dev/null; then
    echo "Instalando paru..."
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
fi

# Instalar paquetes necesarios globalmente usando solo paru
paru -S --needed \
    python \
    nodejs \
    ripgrep \
    ctags \
    neovim \
    ruff \
    pyright \
    python-lsp-server \
    python-pynvim \
    vim-language-server \
    vint \
    lua-language-server \
    stylua \
    sqlfluff \
    sqls \
    clang \
    clang-format-static-bin \
    ccls \
    typescript \
    typescript-language-server \
    prettier \
    yamllint \
    yaml-language-server \
    taplo-cli \
    shellcheck \
    shfmt \
    bash-language-server \
    haskell-ormolu \
    haskell-language-server \
    hlint \
    ghc \
    haskell-hunit


# Instalar vint (linter para Vim script)

echo "Instalación de paquetes completada."
