pkgs:
let
  python = pkgs.python3.withPackages (p: with p; [ fonttools ]);

  font = pkgs.lib.pipe pkgs.nerd-fonts.iosevka [
    (x: "${x}/share/fonts/truetype/NerdFonts/Iosevka/IosevkaNerdFont-Regular.ttf")
    (x: (pkgs.runCommand "iosevka" {
      nativeBuildInputs = with pkgs; [ python woff2 ];
    }) ''
      mkdir -p $out
      python ${./subset.py} ${x} $out/iosevka.ttf
      woff2_compress $out/iosevka.ttf
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
      substituteInPlace layout.pug \
        --replace-fail @hash@ $out

      cp -r static $out
      for i in ${font}/*; do ln -s $i $out; done
      bash processStuff.sh
      pug3 -o $out index.pug
    '';
  };
in
homepage
