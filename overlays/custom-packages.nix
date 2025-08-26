inputs: final: prev: 
let
  customPackages = import ../pkgs { pkgs = prev; };
in
customPackages