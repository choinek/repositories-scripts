#!/bin/bash

mkdir -p public/download
for dir in ./*-scripts/; do
    if [[ -d "$dir" ]]; then
        zip -r "public/download/$(basename "$dir").zip" "$dir"
    fi
done
