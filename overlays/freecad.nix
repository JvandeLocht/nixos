inputs: final: prev: {
  freecad = prev.symlinkJoin {
    name = "freecad-wrapped";
    paths = [ prev.freecad ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild =
      let
        pyEnv = prev.python3.withPackages (ps: [
          ps.requests
          ps.gitpython
        ]);
      in
      ''
        wrapProgram $out/bin/FreeCAD \
          --prefix PYTHONPATH : "${pyEnv}/${prev.python3.sitePackages}"
      '';
  };
}
