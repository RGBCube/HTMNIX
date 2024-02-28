#!/bin/sh

set -e # Fail fast.

rm -rf _site

# Creates all dirs needed.
for dir in $(find site -type d); do
  mkdir -p "_$dir"
done

if [[ "$HTMNIX_LOCAL" == 1 ]]; then
  FLAKE_REF=.
else
  FLAKE_REF=github:RGBCube/HTMNIX
fi

for file in $(find site -type f); do
  if [[ ! "$file" =~ ^_ ]]; then
    if [[ "$file" =~ .nix$ ]]; then
      echo "Processing file $file to _${file%.nix}.html..."
      TARGET_FILE="$file" nix eval "$FLAKE_REF#result" --apply toString --raw > "_${file%.nix}.html"
      echo "Done!"
    else
      echo "Copying file $file to _$file..."
      cp "$file" "_$file"
      echo "Done!"
    fi
  fi
done

echo "All done!"
