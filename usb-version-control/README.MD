# Monitoring and Security Based Bash Scripts 📜🔒

## Description
**Monitoring and Security Based Bash Scripts** is a collection of quirky yet practical bash scripts written for personal and project use. These scripts address specific functionalities centered around monitoring, security, and version control. While originally created for my own use, they may be useful to others with similar needs or to those curious about how such tools work. Feel free to fork, improve, or use these scripts as a base for your own projects. Contributions are welcome! 🚀

## More Information
This project was created for fun and utility. Although some scripts may need occasional updates, they have been optimized for my use and function well in recent tests. If you have suggestions for improvement or would like to contribute, feel free to get involved.

### Open Source Love ❤️
I'm a big believer in open source. Open-source projects foster collaboration and help improve the tech ecosystem by making tools and knowledge accessible to everyone. While some software may need to be closed for security reasons, I believe most tools benefit from being open and shared.

## Available Scripts

### 1. Simple Fast Network Monitor 🌐⚡
A fast script that provides real-time network information, including:
- VPN, Tor, and Proxy status
- Open ports with color-coded indicators (safe, risky, forwarded)
- IP address and geographical location
- System performance metrics (CPU, Memory, Disk)
- Network usage statistics

**Usage:**
```bash
./network-monitor.sh
```

### 2. Bitcoin Crypto Monitor And Analyzer ₿🔍
This script helps you monitor your Bitcoin node using `bitcoind` and `bitcoin-cli`. It refreshes every 5 seconds and displays critical Bitcoin Core metrics, such as:
- Block height
- Connections
- Wallet balance
- Mempool statistics
- Blockchain synchronization progress
- Tor routing status

**Usage:**
```bash
./crypto-monitor.sh
```

### 3. USB Version Control 💾🔑
This script provides a simple, USB-based version control system. If you prefer not to use online or self-hosted version control solutions, this tool allows you to manage projects via USB. It includes branch management, encryption, file filtering, and cloning.

**Commands:**
- `--init`: Initializes a repository on the USB drive.
- `--push`: Pushes the current project state to the USB.
- `--pull`: Pulls the latest changes from the USB.
- `--encrypt`: Encrypts the project or branch.
- `--decrypt`: Decrypts an encrypted project or branch.
- `--clone`: Clones a project from the USB.
- `--status`: Displays available branches in the repository.

**Usage Examples:**

Initialize a repo:
```bash
./usb-vc.sh --init --usb-name <usb-name>
```

Push a branch:
```bash
./usb-vc.sh --push --usb-name <usb-name> --branch <branch-name>
```

Encrypt a branch:
```bash
./usb-vc.sh --encrypt --usb-name <usb-name> --branch <branch-name>
```

Clone a branch:
```bash
./usb-vc.sh --clone --usb-name <usb-name> --branch <branch-name> --decrypt
```

## How to Use

### 1. Clone the Repository
First, clone the repository to your local machine:
```bash
git clone https://github.com/your-username/monitoring-security-bash-scripts.git
cd monitoring-security-bash-scripts
```

### 2. Make Scripts Executable
Before running any scripts, make them executable:
```bash
chmod +x *.sh
```

### 3. Run the Desired Script
To run any script, simply use:
```bash
./<script-name>.sh
```
For example, to run the network monitor:
```bash
./network-monitor.sh
```

### 4. Modify and Customize
Feel free to modify the scripts to suit your specific needs. These scripts are open-source, so customization is encouraged! 💻✨

## Contributing
Contributions are more than welcome! If you have ideas for improvements, bug fixes, or new features, follow these steps:
1. Fork the repository
2. Make your updates
3. Submit a pull request

Let's make these tools even better together!

## License 📄
This project is licensed under the **MIT License**, allowing free use, modification, and distribution.

## Final Thoughts
This project started as a fun side experiment and grew into a useful set of tools. The scripts help with monitoring and security in different ways, and I hope they will be as useful to you as they are to me. If you have any feedback, suggestions, or just want to chat about scripting, feel free to reach out!

Happy scripting! 😎🔧
