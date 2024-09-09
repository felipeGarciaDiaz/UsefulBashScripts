#!/bin/bash

# Define safe ports array
safe_ports=(22, 21, 20, 25, 80, 443, 9050, 9051)

# Function to monitor the system
monitor_system() {
  while true; do
    local_ip=$(hostname -I | cut -d' ' -f1)
    external_ip=$(curl -s https://ipinfo.io/ip)
    geo_info=$(curl -s https://ipinfo.io/${external_ip}/json | jq -r ".city, .region, .country")
    vpn_check=$(ip a | grep tun0)
    proxy_check=$(curl -s -I https://check.torproject.org/ | grep -o "You are not using Tor")
    tor_check=$(curl --socks5-hostname 127.0.0.1:9050 -s https://check.torproject.org/ | grep -o "Congratulations. This browser is configured to use Tor.")
    open_ports=$(netstat -tuln | grep LISTEN | awk -F: '{print $2}' | awk '{print $1}')
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1 "%"}')
    memory_usage=$(free -m | awk '/Mem:/ {printf("%d/%dMB (%.2f%%)", $3, $2, $3*100/$2)}')
    disk_usage=$(df -h / | awk '/\// {print $3 "/" $2 " (" $5 ")"}')

    # Network usage
    net_usage=$(vnstat --json 1 | jq -r '.interfaces[0].traffic.total | "Upload: " + (.tx | tostring) + "KB, Download: " + (.rx | tostring) + "KB"')

    # Color Handling
    green=$(tput setaf 2)
    red=$(tput setaf 1)
    yellow=$(tput setaf 3)
    orange=$(tput setaf 214)
    purple=$(tput setaf 5)
    reset=$(tput sgr0)

    # VPN Status Color
    vpn_color=$([ -n "${vpn_check}" ] && echo "${green}" || echo "${red}")

    # Proxy Status Color
    proxy_color=$([ -z "${proxy_check}" ] && echo "${green}" || echo "${red}")

    # Tor Status Color
    tor_color=$([ -n "${tor_check}" ] && echo "${green}" || echo "${red}")

    # Function to check if a port is forwarded
    is_port_forwarded() {
      local port=$1
      ss -tuln | grep ":${port}" > /dev/null 2>&1
      return $?
    }

    # Open Ports - Color code the ports
    port_output=""
    for port in ${open_ports}; do
      is_safe=0
      for safe_port in "${safe_ports[@]}"; do
        if [ "$port" -eq "$safe_port" ]; then
          is_safe=1
          break
        fi
      done
      
      is_port_forwarded "$port"
      forwarded=$?

      if [ "$is_safe" -eq 1 ] && [ "$forwarded" -eq 0 ]; then
        # Purple: Safe port and forwarded
        port_output="${port_output}${purple}${port}, "
      elif [ "$is_safe" -eq 1 ]; then
        # Green: Safe port
        port_output="${port_output}${green}${port}, "
      elif [ "$forwarded" -eq 0 ]; then
        # Orange: Not in safe ports and forwarded
        port_output="${port_output}${orange}${port}, "
      else
        # Yellow: Not in safe ports and not forwarded
        port_output="${port_output}${yellow}${port}, "
      fi

      if [ "$is_safe" -eq 0 ] && [ "$forwarded" -eq 0 ]; then
        # Red: Both not in safe ports and forwarded
        port_output="${port_output}${red}${port}, "
      fi
    done

    # Output the results with the requested formatting and colors
    clear
    echo "IP Address: ${external_ip}"
    echo

    echo "Local Device IP: ${local_ip}"
    echo

    echo "VPN Active: ${vpn_color}$(if [ -n "${vpn_check}" ]; then echo "YES"; else echo "NO"; fi)${reset}"
    echo

    echo "VPN Location: ${geo_info}"
    echo

    echo "Proxy Active: ${proxy_color}$(if [ -z "${proxy_check}" ]; then echo "YES"; else echo "NO"; fi)${reset}"
    echo

    echo "Tor Active: ${tor_color}$(if [ -n "${tor_check}" ]; then echo "YES"; else echo "NO"; fi)${reset}"
    echo

    echo "PC Performance Usage: CPU ${cpu_usage}, Memory ${memory_usage}, Disk ${disk_usage}"
    echo

    echo "Network Usage: ${net_usage}"
    echo

    echo "Active Device Ports: ${port_output}${reset}"
    
    sleep 5
  done
}

# Start the system monitoring
monitor_system
