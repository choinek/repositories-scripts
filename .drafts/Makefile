.PHONY: help

# Displays a list of commands and their descriptions
help:
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?#"} /^[a-zA-Z_-]+:.*?#/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort


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

# Function to extract and format output
format_block = \
    name=$$(echo "$$line" | grep -o 'name=[^ ]*' | cut -d= -f2); \
    desc=$$(echo "$$line" | grep -o 'desc="[^"]*"' | cut -d= -f2 | tr -d '"'); \
    echo "block $$name have description $$desc"

# Function to find all @Block comments and format output
list_blocks = \
    grep '\#'' @Block' $(MAKEFILE_LIST) | while IFS= read -r line; do \
        $(format_block); \
    done

.PHONY: list
# Target to list all defined groups
list:
	@echo "Listing all blocks:"
	@$(list_blocks)


# Define blocks in the Makefile
# @Block block group;; Example1;; "First Example"
# @Block block group;; Example2;; "Second Example"
# @Block block group;; Example3;; "Third Example"

# Function to process blocks using a callback
cssh_read_short = \
    grep '^# @Block block' $(MAKEFILE_LIST) | while IFS= read -r line; do \
        params=$$(echo "$$line" | sed 's/^# @Block block //'); \
        IFS=';;' read -r type name desc <<< "$$params"; \
        type=$$(echo "$$type" | xargs); \
        name=$$(echo "$$name" | xargs); \
        desc=$$(echo "$$desc" | xargs); \
        $(1) "$$type" "$$name" "$$desc"; \
    done

process_block = \
    echo "block $$2 of type $$1 has description $$3"

.PHONY: listShort
listShort:
	@echo "Listing short all blocks:"
	@$(call cssh_read_short,$(process_block))
