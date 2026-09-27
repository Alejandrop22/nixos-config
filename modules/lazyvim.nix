{ pkgs, ... }: {
  home.packages = with pkgs; [
    gcc
    gnumake
    cmake
    pkg-config
    gdb
    clang-tools   # clangd LSP + clang-format
    unzip
    wget
    lazygit
    ripgrep
    fd
    fzf
    nodejs
    python3
    stylua
    shfmt
    (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
      p.c p.cpp p.lua p.python p.rust
      p.typescript p.tsx p.javascript
      p.html p.css p.json p.json5
      p.bash p.vim p.vimdoc p.query
      p.markdown p.markdown_inline
      p.yaml p.toml p.regex p.diff
      p.xml p.jsdoc p.luadoc p.ninja
      p.rst p.printf p.luap p.ron p.dtd
    ]))
  ];
}
