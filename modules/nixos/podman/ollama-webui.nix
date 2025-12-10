{
  pkgs,
  lib,
  config,
  ...
}: {
  options.podman.openWebUI = {
    enable = lib.mkEnableOption "Set up Ollama Web UI container";
  };

  config = lib.mkIf config.podman.openWebUI.enable {
    # Create directories and run scripts for the containers
    system.activationScripts = {
      script.text = ''
        install -d -m 755 /home/jan/open-webui/data -o root -g root
      '';
    };

    virtualisation.oci-containers.containers = {
      ollama-webui = {
        image = "ghcr.io/open-webui/open-webui:main";

        environment = {
          "TZ" = "Europe/Amsterdam";
          "OLLAMA_API_BASE_URL" = "http://127.0.0.1:11434/api";
          "OLLAMA_BASE_URL" = "http://127.0.0.1:11434";
        };

        volumes = [
          "/home/jan/open-webui/data:/app/backend/data"
        ];

        ports = [
          "127.0.0.1:3000:8080" # Ensures we listen only on localhost
        ];

        extraOptions = [
          "--pull=newer" # Pull if the image on the registry is newer
          "--name=open-webui"
          "--hostname=open-webui"
          "--network=host"
          "--add-host=host.containers.internal:host-gateway"
        ];
      };
    };
  };
}
