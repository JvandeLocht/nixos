inputs: final: prev: {
  st = prev.st.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (prev.fetchpatch {
        url = "https://st.suckless.org/patches/glyph_wide_support/st-glyph-wide-support-20220411-ef05519.diff";
        sha256 = "sha256-nGVswWAJhIhHq0s6+hiVaKLkYKog1mEhBUsLzJjzN+g=";
      })
      (prev.fetchpatch {
        url = "https://st.suckless.org/patches/defaultfontsize/st-defaultfontsize-20210225-4ef0cbd.diff";
        sha256 = "sha256-CPtmRUPqcyY1j8jGUI3FywDJ26+xgRDZjx+oTewI8AQ=";
      })
      (prev.fetchpatch {
        url = "https://st.suckless.org/patches/anygeometry/st-anygeometry-0.8.1.diff";
        sha256 = "sha256-mxxRKzkKg7dIQBYq5qYLwlf77XNN4waazr4EnC1pwNE=";
      })
      (prev.fetchpatch {
        url = "https://st.suckless.org/patches/gruvbox/st-gruvbox-dark-0.8.5.diff";
        sha256 = "sha256-dOkrjXGxFgIRy4n9g2RQjd8EBAvpW4tNmkOVj4TaFGg=";
      })
    ];
  });
}