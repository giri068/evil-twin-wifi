#!/bin/bash
set -e

CONFIG_FILE="./.evil_twin.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[-] Configuration file not found! Cannot determine interfaces."
    exit 1
fi

source "$CONFIG_FILE"

echo "[*] Stopping hostapd and dnsmasq..."
sudo pkill hostapd 2>/dev/null || true
sudo pkill dnsmasq 2>/dev/null || true

echo "[*] Flushing iptables rules..."
sudo iptables -F
sudo iptables -t nat -F

echo "[*] Resetting Wi-Fi interface $WIFI_IFACE..."
sudo ifconfig $WIFI_IFACE down
sleep 2
sudo ifconfig $WIFI_IFACE up

# Restore original SSID and interface placeholders
if [ ! -z "$ORIG_SSID" ]; then
    sed -i "s/^ssid=.*/ssid=$ORIG_SSID/" hostapd.conf
    echo "[*] Restored original SSID: $ORIG_SSID"
fi

sed -i "s/^interface=.*/interface=__WIFI_IFACE__/" hostapd.conf
sed -i "s/^interface=.*/interface=__WIFI_IFACE__/" dnsmasq.conf
echo "[*] Restored interface placeholders in hostapd.conf and dnsmasq.conf"

# Remove config file for fresh next attack
rm -f "$CONFIG_FILE"

echo "[*] Evil Twin attack stopped. Wi-Fi adapter reset."
