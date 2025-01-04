# Choinek's Scripts

Custom scripts by Choinek for working with open-source repositories.

## Requirements

- **Bash**: The scripts use `bash` for features.
- **Git**: The script integrates with Git hooks for automation.

## License

This project is licensed under the MIT License:

```
MIT License

Copyright (c) 2024-2025 Adrian Chojnicki

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

## Scripts

### Text-Includer

The **Text-Includer** is a flexible script designed to process text files with placeholders and replace them dynamically
with content from other files. It is particularly useful for generating documentation files like `README.md` by
including content from other files such as `LICENSE`.

#### How It Works

The Text-Includer script scans a source file for placeholders in the format:

```text
{{text-includer:v1:loadfile:<file>:<start_marker>:<end_marker>}}
```

- `<file>`: The file to extract content from.
- `<start_marker>`: The marker in `<file>` where the included content starts.
- `<end_marker>`: The marker in `<file>` where the included content ends.

Example placeholder:

```text
{{text-includer:v1:loadfile:LICENSE:#1:#2}}
```

This placeholder will include the content between `#1` and `#2` in the `LICENSE` file.

#### Installation

**1. Install Choinek's Scripts:**


(@todo i will put here curl to install after deploy to github pages - few thousand minutes from now :P)

**2. Run the Installer Script**

```bash
sh ./choinek-scripts/install-text-includer-hook.sh
```

You will be prompted to enter:

- The source file path (e.g., `README.md.source`).
    - _Check_ [_Usage_](#Usage) _for more details._
- The output file path (e.g., `README.md`).

**3. Verify the Pre-commit Hook**

The installer will create or update the `.git/hooks/pre-commit` file to include the text-includer logic. It will:

- Generate the output file (e.g., `README.md`) before every commit.
- Ensure the placeholders in the source file are replaced with the correct content.

### Usage

#### 1. Prepare Your Source File

Add placeholders to your source file using the format:

```text
{{text-includer:v1:loadfile:<file>:<start_marker>:<end_marker>}}
```

#### 2. Modify Referenced Files

Ensure the referenced files (e.g., `LICENSE`) contain the markers and content to be included.

#### 3. Commit Changes

When you commit, the pre-commit hook will automatically generate the output file by replacing the placeholders in the
source file.

### Example

#### Source File: `README.md.source`

```markdown
# Project Name

## License

{{text-includer:v1:loadfile:LICENSE:#1:#2}}
```

#### Referenced File: `LICENSE`

```text
#1
This is the included license content.
#2
```

#### Generated Output: `README.md`

```markdown
# Project Name

## License

This is the included license content.
```
