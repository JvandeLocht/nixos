inputs: final: prev: {
  freecad = prev.freecad.overrideAttrs (
    oldAttrs:
    let
      pyEnv = prev.python3.withPackages (ps: [
        ps.requests
        ps.gitpython
      ]);
    in
    {
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.makeWrapper ];

      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/FreeCAD \
            --prefix PYTHONPATH : "${pyEnv}/${prev.python3.sitePackages}"
        '';
    }
  );
}