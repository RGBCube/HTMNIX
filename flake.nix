{
  outputs = { self }: let
    firstChar     = builtins.substring 0 1;
    dropFirstChar = string: builtins.substring 1 (builtins.stringLength string) string;

    lastChar     = string: builtins.substring (builtins.stringLength string - 1) 1 string;
    dropLastChar = string: builtins.substring 0 (builtins.stringLength string - 1) string;

    getType = item: item._type or null;

    escape = s: s; # TODO

    domListToString = _: escape "TODO";
  in {

    __findFile = _: name: if firstChar name == "." then {
      _type = "end";
      _name = dropFirstChar name;
    } else if lastChar name == "." then {
      _type = "lone";
      _name = dropLastChar name;
    } else {
      _type = "start";
      _name = name;

      _accum = [];
      __functor = let
        impl = this: next: if
          getType next == "end" &&
          next._name == this._name
        then
          domListToString this
        else this // {
          _accum = this._accum ++ [ next ];
          __functor = impl;
        };
      in impl;
     };

    result = let inherit (self) __findFile; in
      <html>
        <head>
          <meta.>{charset="UTF-8";}
          <title>"Hello, internet!"<.title>
        <.head>
        <body>
          <p>"What the fuck is this?"<.p>
        <.body>
      <.html>;
  };
}
