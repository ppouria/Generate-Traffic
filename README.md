
# Generate-Traffic

## Overview

The **Traffic Generator Script** is a Bash script designed to generate outbound network traffic by downloading a specified file multiple times in parallel. This tool is ideal for testing network bandwidth, simulating traffic loads, or performing stress tests on network configurations. After completing the downloads, the script installs and launches `btop`, a real-time system monitoring tool, allowing you to visualize network traffic and system resource usage.

## Features

- **Customizable Downloads**: Specify the download URL, the number of parallel downloads, and the total traffic to generate.
- **Progress Monitoring**: Displays a single progress percentage indicating the completion status.
- **Resource Monitoring**: Automatically installs and launches `btop` to monitor CPU, memory, and network usage.
- **Efficient Resource Usage**: Downloads are directed to `/dev/null` to prevent disk space consumption.
- **Graceful Termination**: Easily stop the script using `Ctrl + C`, ensuring all background processes are terminated safely.

## Prerequisites

- **Operating System**: Debian-based Linux distribution (e.g., Ubuntu)
- **Tools**: `bash`, `curl`, `wget`, `bc`
- **Permissions**: `sudo` privileges for installing packages

## Installation

### Using `curl`:

```bash
bash <(curl -s https://raw.githubusercontent.com/ppouria/Generate-Traffic/main/main.sh)
```

### Or Clone the Repository

```bash
git clone https://github.com/ppouria/Generate-Traffic.git
cd Generate-Traffic
```

### Make the Script Executable

```bash
chmod +x main.sh
```

## Usage

Run the script by executing the `main.sh` file:

```bash
./main.sh
```

### Interactive Prompts

Upon execution, the script will prompt you for the following inputs:

1. **Download URL**

   - **Prompt**: `Enter the download URL:`
   - **Description**: The direct link to the file you wish to download. Ensure that the URL is valid and accessible.
   - **Example**: `http://example.com/path/to/file.zip`

2. **Number of Parallel Downloads**

   - **Prompt**: `Enter the number of parallel downloads [100]:`
   - **Description**: The number of simultaneous download threads. This determines how many downloads will run concurrently.
   - **Default Value**: `100`
   - **Recommendation**: Adjust based on your server's capacity and the target server's ability to handle multiple connections.

3. **Total Traffic to Generate**

   - **Prompt**: `Enter the total traffic to generate (e.g., 1TB, 500GB):`
   - **Description**: The total amount of data to be downloaded to generate outbound traffic.
   - **Default Value**: `100GB`
   - **Example**: Entering `1TB` will result in approximately 1 Terabyte of data being downloaded.

### Example Interaction

```
Enter the download URL: http://example.com/path/to/file.zip
Enter the number of parallel downloads [100]: 
Enter the total traffic to generate (e.g., 1TB, 500GB): 
Progress: 0.00% (0/100)
Progress: 1.00% (1/100)
...
Progress: 100.00% (100/100)
```

In this example, the script uses the default values of `100` for parallel downloads and `100GB` for total traffic. It will initiate 100 parallel downloads, each downloading the specified file multiple times to reach the desired traffic volume.

## How It Works

1. **Traffic Calculation**

   - Converts the total traffic input (e.g., `1TB`, `500GB`) to megabytes.
   - Determines the size of the file to be downloaded by fetching the `Content-Length` from the HTTP headers.
   - Calculates the total number of downloads required to achieve the specified traffic volume based on the file size.

2. **Download Execution**

   - Initiates the specified number of parallel download threads.
   - Each download is performed silently (`wget -q`) and directed to `/dev/null` to prevent disk usage.
   - Progress is tracked by counting successful downloads and updating the user on the completion percentage.

3. **Progress Display**

   - Continuously updates the user with the current progress percentage and the number of completed downloads.

## Troubleshooting

- **HTTP Errors (e.g., 460, 503)**: If you encounter errors related to the download URL, consider reducing the number of parallel downloads or verifying the URL's reliability.
  
- **`btop` Installation Issues**: If `btop` fails to install via `apt`, you can install it from the source by following the instructions on its [GitHub repository](https://github.com/aristocratos/btop).
  
- **Network Limitations**: Ensure your server's network configuration allows multiple simultaneous connections without restrictions.
  
- **Script Failures**: Ensure all variables are correctly set and that `curl` is installed on your system.


## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Contact

For any questions or support, please open an issue on the [GitHub repository](https://github.com/ppouria/Generate-Traffic).
