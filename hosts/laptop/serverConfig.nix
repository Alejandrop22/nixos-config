{ config, pkgs, lib, ... }:
{
  specialisation."server".configuration = {
    services.xserver.enable = lib.mkForce false;
    services.displayManager.enable = lib.mkForce false;
    services.displayManager.autoLogin.enable = lib.mkForce false;
    programs.niri.enable = lib.mkForce false;
    services.pipewire.enable = lib.mkForce false;
    home-manager.users.cedric = lib.mkForce (import ../../home/server/home.nix);

    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };

    networking.networkmanager.wifi.powersave = false;

    services.immich = {
      enable = true;
      port = 2283;
      mediaLocation = "/var/lib/immich";
    };

    networking.firewall.allowedTCPPorts = [ 2283 ];
  };
}
