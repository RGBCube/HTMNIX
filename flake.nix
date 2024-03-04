{
  description = "Write composeable HTML with Nix!";

  inputs.nixpkgslib.url = "github:nix-community/nixpkgs.lib";

  outputs = { self, nixpkgslib }: let
    inherit (nixpkgslib) lib;

    first     = n: lib.substring 0 n;
    dropFirst = n: string: lib.substring n (lib.stringLength string - n) string;

    last     = n: string: lib.substring (lib.stringLength string - n) n string;
    dropLast = n: string: lib.substring 0 (lib.stringLength string - n) string;

    escapix = import ./escape.nix lib;
    inherit (escapix) escape;

    attrsetToHtmlAttrs = attrs:
      lib.concatStringsSep " "
        (lib.mapAttrsToList (k: v: ''${k}="${escape (toString v)}"'') attrs);

    dottedNameToTag = name:
      if first 1 name == "."
      then "</${dropFirst 1 name}>"

      else if last 1 name == "."
      then "<${dropLast 1 name}/>"

      else "<${name}>";
  in {
    inherit (escapix) raw;
    inherit lib;

    call = builtins.scopedImport self;

    withDoctype = body: "<!DOCTYPE html>${body}";

    result = self.call /${builtins.getEnv "TARGET_FILE"};

    __findFile = _: name: {
      outPath = dottedNameToTag name;

      __functor = this: next:
        # Not an attrset. Just add it onto the HTML.
        if !lib.isAttrs next
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
        else if lib.isAttrs next && !(next ? outPath)
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
  };
}
