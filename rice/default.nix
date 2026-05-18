{ lib, ... }:
let inherit (lib) elem flip; in {
  imports =
    # TODO upstream to aquaris
    let
      inherit (lib)
        all
        filter
        flatten
        hashFile
        id
        mapAttrsToList
        match
        pipe
        readDir
        unsafeGetAttrPos
        ;

      importTree = root: skip:
        let
          self = pipe { a = 0; } [
            (unsafeGetAttrPos "a")
            (x: x.file)
            (hashFile "sha256")
          ];

          go = dir: pipe (readDir (root + dir)) [
            (mapAttrsToList (name: type:
              let path = dir + "/" + name; in
              if type == "directory" then go path
              else if all id [
                (type == "regular")
                (match ".*[.]nix" name != null)
                (hashFile "sha256" (root + path) != self)
              ] then path
              else [ ]))
            flatten
          ];
        in
        pipe "" [
          go
          (filter (x: !(skip x)))
          (map (x: root + x))
        ];
    in
    importTree ./. (flip elem [
      "/common/patches/infuse.nix"
    ]);
}
