{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.floorp;
    profiles = {
      "main" = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          proton-pass
          i-dont-care-about-cookies
        ];
      };
    };
  };
}
