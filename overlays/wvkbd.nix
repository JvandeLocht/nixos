inputs: final: prev: {
  wvkbd = prev.wvkbd.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ../patches/switchYandZ.patch ];
  });
}