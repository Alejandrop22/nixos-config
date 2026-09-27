{ config, pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      gc = "sudo nix-collect-garbage -d";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#desktop";
      laptop-rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#laptop";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
    };

    # Source P10k theme and its instant prompt
    initExtra = ''
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      export POWERLEVEL9K_CONFIG_FILE=~/nixos-config/dotfiles/p10k/.p10k.zsh
      [[ -f ~/nixos-config/dotfiles/p10k/.p10k.zsh ]] && source ~/nixos-config/dotfiles/p10k/.p10k.zsh
    '';
  };
  
  programs.zsh.plugins = [
    {
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }
  ];
}
