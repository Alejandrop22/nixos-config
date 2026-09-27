{ config, pkgs, lib, ... }:
{
  imports = [ 
    ./hardware-configuration.nix
    ./normalConfig.nix
    ./serverConfig.nix
  ];

  # ===== Base =====
  networking.hostName = "laptop";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Tijuana";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.cedric = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };
  programs.zsh.enable = true;

  services.openssh.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  home-manager.backupFileExtension = "backup";
  services.tailscale.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim 
    ghostty 
  ];

  system.stateVersion = "25.11";
}
