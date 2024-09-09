#!/bin/bash

# Function to monitor Bitcoin node
monitor_bitcoin() {
  while true; do
    # Get general Bitcoin Core info
    block_height=$(bitcoin-cli getblockcount 2>/dev/null)
    network_info=$(bitcoin-cli getnetworkinfo 2>/dev/null)
    mempool_info=$(bitcoin-cli getmempoolinfo 2>/dev/null)
    balance=$(bitcoin-cli getbalance 2>/dev/null)
    blockchain_info=$(bitcoin-cli getblockchaininfo 2>/dev/null)

    # Check if Bitcoin Core is routing through Tor
    tor_check=$(echo "${network_info}" | grep '"proxy"' | grep '127.0.0.1:9050')

    # Parse the info
    connections=$(echo "${network_info}" | jq '.connections')
    version=$(echo "${network_info}" | jq '.version')
    tor_status=$(if [ -n "${tor_check}" ]; then echo "YES"; else echo "NO"; fi)

    # Get Mempool stats
    mempool_size=$(echo "${mempool_info}" | jq '.size')
    mempool_bytes=$(echo "${mempool_info}" | jq '.bytes')

    # Get Blockchain progress
    verification_progress=$(echo "${blockchain_info}" | jq '.verificationprogress')
    chain=$(echo "${blockchain_info}" | jq -r '.chain')
    block_size=$(echo "${blockchain_info}" | jq '.size_on_disk')

    # Color Handling
    green=$(tput setaf 2)
    red=$(tput setaf 1)
    reset=$(tput sgr0)

    # Tor Status Color
    if [ "${tor_status}" == "YES" ]; then tor_color=${green}; else tor_color=${red}; fi

    # Output the results with the requested formatting and colors
    clear
    echo "Bitcoin Node Status:"
    echo "======================"
    echo "Block Height: ${block_height}"
    echo "Connections: ${connections}"
    echo "Bitcoin Core Version: ${version}"
    echo "Blockchain: ${chain}"
    echo "Verification Progress: $(printf '%.4f' "${verification_progress}")"
    echo "Disk Space Used by Blockchain: ${block_size} bytes"
    echo "Mempool Size: ${mempool_size} transactions"
    echo "Mempool Usage: ${mempool_bytes} bytes"
    echo
    echo "Tor Network Routing: ${tor_color}${tor_status}${reset}"
    echo
    echo "Wallet Balance: ${balance} BTC"
    echo
    echo "======================"
    echo "Refreshing every 5 seconds..."
    
    # Wait 5 seconds before refreshing
    sleep 5
  done
}

# Start the Bitcoin monitor
monitor_bitcoin
