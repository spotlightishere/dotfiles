{ config, lib, pkgs, ... }:

{
  programs.vim = {
    enable = true;
    # Let's not grab _all_ of Vim.
    packageConfigurable = pkgs.vim;
    plugins = with pkgs; [
      pkgs.vimPlugins.vim-airline
      pkgs.vimPlugins.vim-airline-themes
    ];

    settings = {
      number = true;

      # Two-spaced tabs
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };
    extraConfig = ''
      syntax on
      filetype plugin indent on
      set backspace=indent,eol,start

      " assistance with space-oriented tabs
      set softtabstop=2
      set smarttab

      " custom filetypes
      autocmd BufNewFile,BufRead *.plist set syntax=xml

      " vim-airline
      let g:airline_powerline_fonts = 1
    '';
  };
}