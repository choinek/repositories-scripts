# Choinek Mac Mimic Scripts

Custom scripts by **Choinek** for Mac users to mimic Linux functionality.

## Free

- Similar to Linux `free` Command
  - **Display memory and swap usage statistics**
  - **Memory Monitoring:** Display total, used, free, shared, buff/cache, and available memory
  - ~~**Swap Information:** Show total, used, and free swap memory~~
  - **Unit Conversion:** View memory in kilobytes (KB), megabytes (MB), or gigabytes (GB)
  - **Continuous Monitoring:** Refresh memory statistics at specified intervals
  - **Color-Coded Output:** Enhance readability with optional colored output

### Installation

#### Prerequisites

- **macOS**: The script is tailored for macOS environments
- **Bash + vm_stat**: (default on macOS)

#### Steps

#### Quick Start

| ⚠️ **Checksum Check**                                                                           |
|-------------------------------------------------------------------------------------------------|
| Checksum verification is recommended after downloading any file. My scripts are not exceptions. |
| You can find checksums on my [**scripts page**](https://choinek.github.io/scripts/)             |

```bash
curl -f -o mac-free.sh https://raw.githubusercontent.com/choinek/scripts/refs/heads/main/mac-linux-mimic-scripts/mac-free.sh && \
echo "bf792cd1810b870af78b01a902fb5c282d160baeeeb77b87dc709d06011bf743  mac-free.sh" | sha256sum -c && \
echo "checksum checked" && \
chmod +x mac-free.sh && \
echo "Need sudo to install..." && \
sudo mv mac-free.sh /usr/local/bin/free && \
echo "Script installed successfully as 'free'" && \
echo "   Usage:" && \
echo "      free --help"
```


#### Detailed Instructions

1. **Clone the Repository:**
    ```bash
    curl -o mac-free.sh https://raw.githubusercontent.com/choinek/scripts/refs/heads/mac-linux-mimic-scripts/mac-free.sh
    ```

2. **Make the Script Executable:**
    ```bash
    chmod +x mac-free.sh
    ```

3. **Move to a Directory in Your PATH and change its name to free so it will be globaly available:**
    ```bash
    sudo mv mac-free.sh /usr/local/bin/free
    ```


### Usage
```bash
free
free -h
free --random-color
```
