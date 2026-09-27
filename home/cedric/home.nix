{ config, pkgs, lib, inputs, system, ... }: {
  home.username = "cedric";
  home.homeDirectory = "/home/cedric";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
 
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  imports = [
    inputs.zen-browser.homeModules.twilight
    ../../modules/lazyvim.nix
    # ../../modules/hyprland.nix
    ../../modules/niri.nix
    ../../modules/ohmyzsh.nix
    ../../modules/languages.nix
    ../../modules/mpd.nix
  ];

  programs.zen-browser.enable = true;

  # symlink for the .dotfile of lazyvim
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/nixos-config/dotfiles/nvim";

  # symlink for the .dotfile of ghostty
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/nixos-config/dotfiles/ghostty/config";

  # noctalia shell symlink config
  xdg.configFile."noctalia/settings.json".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/nixos-config/dotfiles/noctalia/settings.json");
  
  # symlink for rmpc 
  xdg.configFile."rmpc/config.ron".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/nixos-config/dotfiles/rmpc/config.ron";

  programs.git = {
    enable = true;
    settings = {
      user.name = "Cedric Martinez";
      user.email = "cedric.martinez@cetys.edu.mx";
      init.defaultBranch = "main";
      # gpg.format = null;
    };
  };

  home.packages = with pkgs; [
    obsidian
    rmpc
    brave
    steam
    tree
  ];
}
