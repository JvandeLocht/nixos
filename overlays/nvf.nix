inputs: final: prev: {
  nvf = inputs.nvf.packages.${prev.stdenv.hostPlatform.system}.default;
}