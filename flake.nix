{
  description = "Write composeable HTML with Nix!";

  inputs.lib.url = "github:nix-community/nixpkgs.lib";

  outputs = { self, lib }: let
    first     = n: builtins.substring 0 n;
    dropFirst = n: string: builtins.substring n (builtins.stringLength string - n) string;

    last     = n: string: builtins.substring (builtins.stringLength string - n) n string;
    dropLast = n: string: builtins.substring 0 (builtins.stringLength string - n) string;

    escapix = import ./escape.nix lib.lib;
    inherit (escapix) escape;

    attrsetToHtmlAttrs = attrs:
      builtins.concatStringsSep " "
      (builtins.attrValues
        (builtins.mapAttrs (k: v: ''${k}="${escape (toString v)}"'') attrs));

    dottedNameToTag = name:
      if first 1 name == "."
      then "</${dropFirst 1 name}>"

      else if last 1 name == "."
      then "<${dropLast 1 name}/>"

      else "<${name}>";
  in {
    inherit (escapix) raw;

    __findFile = _: name: {
      outPath = dottedNameToTag name;

      __functor = this: next:
        # Not an attrset. Just escape and add it onto the HTML.
        if !builtins.isAttrs next
        then this // {
          outPath = (toString this) + escape (toString next);
        }
        
        # An attrset. But not a tag. This means it must be HTML attributes.
        # We need to insert it right before the '>' or '/>' at the end of our string
        # and error if it doesn't end with a tag.
        #
        # Due to how it is implemented, passing multiple attrsets to a single
        # tag to combine them works. Here is an example:
        #
        #     <foo>{bar="baz";}{fizz="fuzz";}
        #
        # This will output the following HTML:
        #
        #     <foo bar="baz" fizz="fuzz">
        else if builtins.isAttrs next && !(next ? outPath)
        then let
          lastElementIsTag         = last 1 (toString this) == ">";
          lastElementIsSelfClosing = last 2 (toString this) == "/>";
        in this // {
          outPath = let
            attrs = attrsetToHtmlAttrs next;
          in if !lastElementIsTag then
            throw "Attributes must come right after a tag: '${if attrs != "" then attrs else "<empty attrs>"}'"
          else
            (dropLast (if lastElementIsSelfClosing then 2 else 1) (toString this))
            + (if attrs != "" then " " else "") # Keep it pretty.
            + attrs
            + (if lastElementIsSelfClosing then "/>" else ">");
        }
        
        # The next element is a tag with the `outPath` attribute which means it's a
        # start, closing or self closing tag. Just append it onto our string.
        else this // {
          outPath = "${this}${next}";
        };
    };

    result = let
      targetFile = builtins.getEnv "TARGET_FILE";
      targetFile' = if targetFile != "" then targetFile else "site/index.nix";
    in builtins.scopedImport { inherit (self) raw __findFile; } ./${targetFile'};
  };
}
