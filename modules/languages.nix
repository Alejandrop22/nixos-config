{ config, pkgs, lib, ... }: {

  home.packages = with pkgs; [
    # ── Java ──────────────────────────────────────────────────────────────
    jdk21
    maven
    gradle
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";
  };
}
