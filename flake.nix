{
  outputs = { self }: {
    escape = s: s; # TODO

    __findFile = _: name: if builtins.substring 0 1 name == "." then {
      _type = "end";
      _name = builtins.substring 1 (builtins.stringLength name) name;
    } else if builtins.substring (builtins.stringLength name - 1) 1 name == "." then {
      _type = "lone";
      _name = builtins.substring 0 (builtins.stringLength name - 1) name;
    } else {
      _type = "start";
      _name = name;

      _accum = [];
      __functor = let
        impl = this: next: if
          next._type or null == "end" &&
          next._name == this._name
        then
          this._accum
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
