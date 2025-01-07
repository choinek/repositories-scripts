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

##### Quick Start

    ```bash
    curl -o mac-free.sh https://raw.githubusercontent.com/choinek/scripts/refs/heads/mac-linux-mimic-scripts/mac-free.sh
    chmod +x mac-free.sh
    sudo mv mac-free.sh /usr/local/bin/free
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
