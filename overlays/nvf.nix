inputs: final: prev: {
  nvf = inputs.nvf.packages.${prev.system}.default;
}