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
    git-delta\
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
    shfmt \
    shellcheck \
    bash-language-server \
    haskell-hunit \
    haskell-language-server \
    ghc \
    haskell-ormolu \
    hlint \
    haskell-hunit \
    haskell-hoogle \
    ghcid \
    lua-language-server \
    luacheck \
    stylua \
    texlab \
    latexmk

echo "Finished paru installation"
