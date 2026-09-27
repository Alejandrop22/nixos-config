{ config, pkgs, inputs, system, ... }: 
{
  home.packages = with pkgs; [
    wofi
    waybar
    awww
    hyprlock
    # dunst
    # wl-clipboard
    # grim
    # slurp
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    settings = {
      "$mod" = "SUPER";
      monitor = ",preferred,auto,1";
      exec-once = [
        "waybar"
        "dunst"
        "bash -c 'awww-daemon && awww img /home/cedric/nixos-config/dotfiles/wallpapers/little_girl.png --transition-type fade'"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(cba6f7ff)";
        "col.inactive_border" = "rgba(6c7086ff)";
        layout = "dwindle";
      };
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
        };
      };
      animations.enabled = true;
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };
      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
      ];
      cursor = {
        no_hardware_cursors = true;
        inactive_timeout = 3;
      };

      bind = [
        "$mod, Return, exec, ghostty"
        "$mod, Z, exec, zen-twilight"
        "$mod, D, exec, wofi --show drun"
        "$mod, W, killactive"
        "$mod, F, fullscreen"
        "$mod, Space, togglefloating"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
