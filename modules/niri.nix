{ config, pkgs, inputs, system, ... }: {

  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
  };

  home.packages = with pkgs; [
    xwayland-satellite
    wl-clipboard
    swaylock
    nautilus
  ];
  # symlink de niri
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nixos-config/dotfiles/niri/config.kdl";
}
