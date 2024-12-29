#!/bin/bash

mkdir -p public/download
for dir in */; do
    if [[ -d "$dir" ]] && [[ "$dir" != "public/" ]]; then
        zip -r "public/download/${dir%/}.zip" "$dir"
    fi
done
