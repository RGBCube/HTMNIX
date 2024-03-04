# HTMNIX

Write composeable HTML with Nix!

Here is an example snippet:

```nix
<html>
  <head>
    <title>"Hello, Internet!"<.title>
  <.head>
  <body>
      <p>"Yep, this is 100% Nix!"<.p>

      <img.>{src="/foo.png"; alt="Attributes also work!";}
  <.body>
<.html>
```

You might be wondering, _How?_

If you are, go read my [blog post](https://rgbcu.be/blog/htmnix)!

But before that you may want to try it for yourself!
You can! Just enter the REPL by running this command:

```sh
nix repl github:RGBCube/HTMNIX
```

## Provided Functions

These are the functions and variables provided by HTMNIX
which will be available in every HTMNIX file and the HTMNIX REPL
(You can enter it by running `nix repl github:RGBCube/HTMNIX`!).

- `lib`: Just the nixpkgs lib. Pretty useful to have.

- `raw`: Used for a string to be included in the HTML without escaping.
  Just pass the string into this and it will not be escaped.

- `call`: Calls another HTMNIX file and brings this list of provided
  variables into its scope before evaulation. Basically the same as `import`
  if you disregard the bringing-into-scope it does.

- `DOCTYPE`: Equivalent to a `<!DOCTYPE html>` tag, this exists because you can't
  express it in Nix syntax and have to resort to calling `__findFile` with the
  string you want instead.

- `__findFile`: Where the magic happens. This overrides the default `__findFile`
  allowing for us to return magic functor sets for `<whatever.here>` expressions.
  The `<nixpkgs>` expression however is propagated into the builtin one so it does
  not interfere with your workflow.

## More Examples

> All of the examples here can be rendered with the following
> command (assuming `html.nix` has the example content):
>
> ```sh
> TARGET_FILE=$(realpath html.nix) nix eval github:RGBCube/HTMNIX#result --raw --impure
> ```

> Also keep in mind that everything is passed as an argument to the
> first HTML tag's functor. So you will need to surrond some things with
> parens for it to evaulate properly.
>
> Some notable things that require parens include:
> - Function calls.
> - `let in`'s.
> - Expressions that have spaces in them.

Create a directory listing:

```nix
<ul>
  (lib.mapAttrsToList
    (name: type: <li>"${name} (${type})"<.li>)
    (builtins.readDir ./.))
<.ul>
```

List metadata about a derivation:

```nix
let
  pkg = (import <nixpkgs> {}).youtube-dl;
in

<div>{class="package";}
  <p>"Name: ${pkg.pname}"<.p>
  <details>
    <summary>"See metadata"<.summary>
    <ul>
      <li>"Full name: ${pkg.name}"
      <li>"Version: ${pkg.version}"
      <li>(let
        license = if lib.isList pkg.meta.license then
          lib.elemAt pkg.meta.license 0
        else
          pkg.meta.license;
      in "License: ${license.fullName}")
    <.ul>
  <.details>
<.div>
```

Insert a raw unescaped string into your HTML:

```nix
<head>
  <title>"Look ma! So unsafe!"<.title>
<.head>
<body>(raw ''
  <blink>Please don't do this at home...</blink>
'')<.body>
```

Call another Nix file as a HTMNIX file, with all the magic:

```nix
# -- inside customer.nix --
{ name, comment }:

<div>{class="review";}
  <figcaption>
    <img.>{src="/assets/${lib.replaceStrings [ " " ] [ "-" ] name}-headshot.webp";}
    <h2>name<.h2>
  <.figcaption>

  <p>comment<.p>
<.div>

# -- inside html.nix --
let
  comments = [
    { name = "John Doe"; comment = "Very nice service, reversed my hair loss!"; }
    { name = "Joe"; comment = "Didn't work for me. 0/10."; }
    { name = "Skid"; comment = "<script>alert('Got you!')</script>"; } # Does not work as all strings are escaped by default.
  ];
in
<ul>
  (map
    (comment: <li>(call ./comment.nix comment)<.li>)
    comments)
<.ul>
```

## License

```
MIT License

Copyright (c) 2024-present RGBCube

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
