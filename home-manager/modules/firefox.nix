{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    profiles = {
      "main" = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          floccus
          darkreader
          ublock-origin
        ];
      };
    };
  };
}
