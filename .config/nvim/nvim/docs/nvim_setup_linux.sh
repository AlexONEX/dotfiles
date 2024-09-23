#!/bin/bash
set -exu
set -o pipefail

# Install paru if it is not installed
if ! command -v paru &> /dev/null; then
    echo "Instalando paru..."
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
fi

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
    haskell-hunit \
    bash-language-server \
    shellcheck \
    shfmt \
    lua-language-server \
    luacheck \
    stylua

echo "Finished paru installation"
