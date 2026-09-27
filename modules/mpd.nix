{ config, pkgs, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/Music";
    network.listenAddress = "127.0.0.1";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
    '';
  };
}
