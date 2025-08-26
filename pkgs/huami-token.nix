{
  python3Packages,
  fetchPypi,
  lib,
}:
python3Packages.buildPythonApplication rec {
  pname = "huami-token";
  version = "0.7.0";
  pyproject = true;

  src = fetchPypi {
    pname = "huami_token";
    inherit version;
    sha256 = "sha256-h6AyPZUwTOZPs/HVFq54NW5DoyImad+ObiUS7Bw4frE=";
  };

  build-system = with python3Packages; [
    flit-core
  ];

  dependencies = with python3Packages; [
    requests
  ];

  doCheck = false; # No tests in the package

  # Override the runtime deps check to be a no-op since newer requests version should work fine
  pythonRuntimeDepsCheckHook = "echo 'Skipping runtime deps check'";

  postPatch = ''
    # Fix __init__.py to export the main function so the entry point works
    substituteInPlace huami_token/__init__.py \
      --replace-fail 'from .huami_token import HuamiAmazfit' 'from .huami_token import HuamiAmazfit, main' \
      --replace-fail '__all__ = ["HuamiAmazfit", "ERRORS", "URLS", "PAYLOADS"]' '__all__ = ["HuamiAmazfit", "ERRORS", "URLS", "PAYLOADS", "main"]'
  '';

  meta = {
    description = "Script to obtain watch or band bluetooth access token from Huami servers";
    homepage = "https://codeberg.org/argrento/huami-token";
    license = lib.licenses.mit;
    mainProgram = "huami_token";
  };
}