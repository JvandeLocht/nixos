{ lib }:
{
  # Mark a package as broken
  markBroken = pkg: pkg.overrideAttrs (old: {
    meta = (old.meta or {}) // {
      broken = true;
    };
  });

  # Remove updateScript from package attributes
  dropAttrsUpdateScript = attrs:
    builtins.removeAttrs attrs [ "updateScript" ];

  # Set platforms for package attributes
  setAttrsPlatforms = platforms: attrs:
    lib.mapAttrs (name: pkg:
      if lib.isDerivation pkg then
        pkg.overrideAttrs (old: {
          meta = (old.meta or {}) // {
            platforms = platforms;
          };
        })
      else pkg
    ) attrs;

  # Shorten a git revision hash
  shorter = rev: builtins.substring 0 7 rev;

  # Conditionally add an attribute
  optionalAttr = name: cond: value:
    if cond then { ${name} = value; } else {};

  # Override a package with full control
  overrideFull = override: pkg: pkg.overrideAttrs override;

  # Apply multiple overrides
  multiOverride = overrides: pkg:
    lib.foldl' (p: override: override p) pkg overrides;
}
