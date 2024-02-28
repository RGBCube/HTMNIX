# Taken from https://github.com/nrabulinski/cursed-nix. Huge thanks!

let
  lib = (import <nixpkgs> {}).lib;

  startMarker = "__START__";
  endMarker   = "__END__";

  dropFirst = lib.drop 1;
  dropLast  = list: lib.sublist 0 (lib.length list - 1) list;

  yeet = string: builtins.unsafeDiscardStringContext (builtins.unsafeDiscardOutputDependency string);

  getContent = drvPath: let
    drv     = builtins.readFile drvPath;
    isValid = builtins.match ".*${lib.escapeRegex startMarker}.*${lib.escapeRegex endMarker}.*" drv != null;
    content = lib.pipe drv [
      (lib.splitString startMarker)
      dropFirst
      (lib.concatStringsSep startMarker)
      (lib.splitString endMarker)
      dropLast
      (lib.concatStringsSep endMarker)
    ];
  in if isValid then content else toString (import drvPath);

  escape = string: let
    ctx      = builtins.getContext string;
    ctxNames = lib.attrNames ctx;

    recurseSubDrv = restNames: strings: let
      head        = lib.head restNames;
      headDrv     = import head;
      last        = (lib.length restNames) == 1;
      headContent = getContent head;
    in map (string: let
      m = lib.splitString (yeet headDrv.outPath) string;
      __m = if last then map lib.strings.escapeXML else recurseSubDrv (lib.tail restNames);
      out = __m m;
    in lib.concatStringsSep headContent out) strings;

    final = recurseSubDrv ctxNames [ string ];
    final' = assert (lib.length final == 1); lib.head final;
  in if builtins.hasContext string then
    yeet final'
  else
    lib.strings.escapeXML string;

  raw = string: derivation {
    name       = "_";
    system     = "_";
    builder    = "_";
    rawContent = "${startMarker}${yeet string}${endMarker}";
  };
in {
  inherit escape raw;
}
