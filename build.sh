#!/bin/sh

set -e # Fail fast.

rm -rf _site

# Creates all dirs needed.
for dir in $(find site -type d); do
  mkdir -p "_$dir"
done

for file in $(find site -type f); do
  if [[ ! "${file##*/}" =~ ^_ ]]; then
    if [[ "$file" =~ .nix$ ]]; then
      echo "Processing file $file to _${file%.nix}.html..."
      TARGET_FILE=$(realpath "$file") nix eval "${HTMNIX_REF:-github:RGBCube/HTMNIX}#result" --impure --raw --apply toString > "_${file%.nix}.html"
    else
      echo "Copying file $file to _$file..."
      cp "$file" "_$file"
    fi
  fi
done
