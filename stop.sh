#!/bin/bash
# Stop Evil Twin Attack

WIFI_IFACE="wlan0"
INTERNET_IFACE="eth0"

echo "[*] Stopping hostapd and dnsmasq..."
sudo pkill hostapd
sudo pkill dnsmasq

echo "[*] Flushing iptables rules..."
sudo iptables -F
sudo iptables -t nat -F

echo "[*] Resetting network interface..."
sudo ifconfig $WIFI_IFACE down
sleep 2
sudo ifconfig $WIFI_IFACE up

echo "[*] Evil Twin attack stopped. Wi-Fi adapter reset."
