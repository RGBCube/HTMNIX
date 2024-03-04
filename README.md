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

## More Examples

> All of the examples here can be rendered with the following
> command (assuming `html.nix` has the example content):
>
> ```sh
> TARGET_FILE=$(realpath html.nix) nix eval github:RGBCube/HTMNIX#result --raw --impure
> ```

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
