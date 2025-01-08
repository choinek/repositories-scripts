#!/bin/bash

# ! Run this script from directory containing script groups
# ! e.g. ./.ach-repository-workflow/actions/action_gh_pages_prepare_zip_script_groups.sh

mkdir -p public/download
for dir in ./*-scripts/; do
    if [[ -d "$dir" ]]; then
        zip -r "public/download/$(basename "$dir").zip" "$dir"
    fi
done
