#!/bin/bash

# @Block type=group name=Example1 desc="First Example"
#
# @Block type=group name=Example2 desc="Second Example"
#
# @Block

# @Block type=group name=Example3 desc="Second Example"

# @Block

# @Block type=group name=Example4 desc="Second Example"

# @Block @Block @Block

# @Block type=group name=Example5 desc="Second Example"


#Some other text

# Read the script itself and process each line

# Read the script itself and process each line
while IFS= read -r line; do
    if [[ $line == *"#"" @Block"* ]]; then
        name=$(echo "$line" | grep -o 'name=[^ ]*' | cut -d= -f2)
        desc=$(echo "$line" | grep -o 'desc="[^"]*"' | cut -d= -f2 | tr -d '"')
        echo "block $name have description $desc"
    fi
done < "$0"

#!/bin/bash

while IFS= read -r line; do
    if [[ $line =~ ^#\ @Block\ block\ (.+)$ ]]; then
        params="${BASH_REMATCH[1]}"

        IFS=';;' read -r type name desc <<< "$params"

        type=$(echo "$type" | xargs)
        name=$(echo "$name" | xargs)
        desc=$(echo "$desc" | xargs)

        echo "block $name of type $type has description $desc"
    fi
done < "$0"
