# TEMP-FIX(droidcam-transform-buffer): fix the tjTransform buffer leak in process_frame().
final: prev: {
  droidcam = prev.droidcam.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./patches/droidcam-transform-buffer.patch
    ];
  });
}
