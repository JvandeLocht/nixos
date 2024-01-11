{
  virtualisation.oci-containers.containers = {
    ollama = {
      image = "ollama/ollama";
      autoStart = true;
      # name = "ollama";
      # gpus = "all";
      # volume = "~/ollama:/root/.ollama";
      ports = [ "127.0.0.1:11434:11434" ];
    };
  };
}
