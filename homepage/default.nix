pkgs:
let
  font = pkgs.lib.pipe pkgs.nerd-fonts [
    (x: x.iosevka)
    (x: "${x}/share/fonts/truetype/NerdFonts/Iosevka/IosevkaNerdFont-Regular.ttf")
    (x: (pkgs.runCommand "iosevka" {
      nativeBuildInputs = with pkgs; [ woff2 ];
    }) ''
      install -D ${x} $out/iosevka.ttf
      woff2_compress  $out/iosevka.ttf
    '')
  ];

  homepage = pkgs.stdenv.mkDerivation {
    name = "homepage";
    src = ./.;

    nativeBuildInputs = with pkgs; [
      glibcLocales
      pug
      tree
    ];

    buildPhase = ''
      cp -r static $out
      for i in ${font}/*; do ln -s $i $out; done
      bash processStuff.sh
      pug3 -o $out index.pug
    '';
  };
in
homepage
