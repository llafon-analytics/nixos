final: prev: {
  droidcam = prev.droidcam.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./patches/droidcam-transform-buffer.patch
    ];
  });
}
