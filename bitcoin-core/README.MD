# Bitcoin Crypto Monitor And Analyzer ₿📊

## Description
**Bitcoin Crypto Monitor And Analyzer** is a lightweight tool designed to monitor and analyze key metrics of your Bitcoin node. It provides real-time updates on essential information like block height, network connections, mempool usage, and wallet balance, while ensuring that your Bitcoin Core node is routed through the Tor network if configured. This tool is ideal for developers, node operators, and Bitcoin enthusiasts who want to stay informed about their node's performance, security, and critical statuses in a simple yet powerful way.

## Features
- **Block Height Monitoring**: Track your node’s current block height in the Bitcoin blockchain.
- **Network Status**: View details about network connections and the Bitcoin Core version.
- **Mempool Stats**: Check the number of transactions and the total size of the mempool.
- **Blockchain Progress**: See the blockchain verification progress and total blockchain size.
- **Tor Network Routing**: Detect whether the node is running through the Tor network for added privacy.
- **Wallet Balance**: View the total balance of your Bitcoin Core wallet.
- **Auto-Refresh**: Automatically updates and displays the latest information every 5 seconds.

## Installation

### 1. Clone the repository:
```bash
git clone https://github.com/your-repo/bitcoin-crypto-monitor.git
cd bitcoin-crypto-monitor
```

### 2. Make the script executable:
```bash
chmod +x bitcoin-crypto-monitor.sh
```

### 3. Install dependencies:
Ensure you have `bitcoin-cli`, `jq`, and `tput` installed on your machine. If not, install them with:
```bash
sudo apt install bitcoin-cli jq ncurses-bin
```

### 4. (Optional) Move the script to a directory in your PATH:
To run the script from anywhere on your system:
```bash
sudo mv bitcoin-crypto-monitor.sh /usr/local/bin/bitcoin-monitor
```

## Usage

### Start the Bitcoin Node Monitor:
Run the script directly from the terminal:
```bash
./bitcoin-crypto-monitor.sh
```

Or, if you've moved it to a directory in your PATH:
```bash
bitcoin-monitor
```

The script will begin monitoring your Bitcoin node, updating every 5 seconds with critical information.

## What the Monitor Displays:
- **Block Height**: The current block height your node is synced to.
- **Connections**: Number of active connections to other Bitcoin nodes.
- **Bitcoin Core Version**: The version of Bitcoin Core running on your node.
- **Blockchain**: The current blockchain being synced (e.g., mainnet, testnet).
- **Verification Progress**: Percentage of blockchain data that has been verified by your node.
- **Disk Space Used**: Total size of the blockchain stored on your node.
- **Mempool Size**: Number of unconfirmed transactions in the mempool.
- **Mempool Usage**: Total size (in bytes) of the unconfirmed transactions in the mempool.
- **Tor Routing**: Whether the node is routed through the Tor network.
- **Wallet Balance**: The total balance of your Bitcoin wallet.

### Example Output:
```bash
Bitcoin Node Status:
======================
Block Height: 753450
Connections: 8
Bitcoin Core Version: 230000
Blockchain: main
Verification Progress: 0.9999
Disk Space Used by Blockchain: 450000000000 bytes
Mempool Size: 112 transactions
Mempool Usage: 300000 bytes

Tor Network Routing: YES

Wallet Balance: 1.2345 BTC
======================
Refreshing every 5 seconds...
```

## How It Works
- **Bitcoin Core Info Retrieval**: The script uses `bitcoin-cli` commands to gather node data such as block height, mempool stats, wallet balance, and blockchain verification progress.
- **Tor Network Check**: The script checks whether the node is being routed through Tor by inspecting the proxy settings in the Bitcoin Core configuration.
- **Real-Time Monitoring**: The script refreshes every 5 seconds to display the latest metrics from your Bitcoin node.
- **Color Coding**: The Tor routing status is color-coded for easy identification:
  - 🟢 **Green**: Node is successfully routing through Tor.
  - 🔴 **Red**: Node is not routing through Tor.

## Customization
You can easily customize the script to fit your needs:
- Modify the refresh rate.
- Change the displayed data.
- Add new features like monitoring other metrics or services.

The script is simple and extensible for those who wish to enhance it further.

## Troubleshooting

### Bitcoin CLI Not Found:
Ensure that `bitcoin-cli` is installed and that your Bitcoin node is running. Check your node configuration to ensure the correct paths and permissions.

### Tor Not Enabled:
If the script shows that Tor is not enabled, check your `bitcoin.conf` file to ensure that Tor routing is properly configured:
```bash
proxy=127.0.0.1:9050
```

## Additional Information
This tool is perfect for monitoring your Bitcoin node, ensuring that it's running properly, secured, and up-to-date with the latest blockchain data. It's a simple yet effective way to stay on top of your node's performance and security without the need to manually run multiple commands.

## License 📄
This project is licensed under the **MIT License**. You are free to use, modify, and distribute the script as you see fit.

## Closing Notes
This tool was designed for Bitcoin enthusiasts, developers, and node operators to keep an eye on their node's performance with minimal effort. Feel free to modify or extend the script to suit your specific needs. If you have any questions or suggestions, don’t hesitate to reach out!

Happy monitoring! 😎🚀
