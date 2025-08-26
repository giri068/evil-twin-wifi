#!/bin/bash
set -e

# === Ensure necessary tools are installed ===
sudo apt update
sudo apt install -y iw ifconfig iproute2 hostapd dnsmasq net-tools iptables

# === Auto-detect Interfaces ===
WIFI_IFACE=$(iw dev | awk '$1=="Interface"{print $2}' | head -n1)
INTERNET_IFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

# Fallback: ask user if auto-detect fails
if [ -z "$WIFI_IFACE" ]; then
    read -p "Enter your WiFi interface (e.g., wlan0, wlp2s0): " WIFI_IFACE
fi

if [ -z "$INTERNET_IFACE" ]; then
    read -p "Enter your Internet interface (e.g., eth0, enp0s3): " INTERNET_IFACE
fi

# === Configurable Inputs ===
AP_IP="192.168.50.1"
NETMASK="255.255.255.0"
HOSTAPD_CONF="./hostapd.conf"
DNSMASQ_CONF="./dnsmasq.conf"

# === Ask user for SSID dynamically ===
read -p "Enter SSID for Fake WiFi: " SSID
sed -i "s/^ssid=.*/ssid=$SSID/" $HOSTAPD_CONF

# === Kill old processes ===
sudo pkill hostapd 2>/dev/null || true
sudo pkill dnsmasq 2>/dev/null || true

echo "[*] Setting static IP on $WIFI_IFACE..."
sudo ifconfig $WIFI_IFACE $AP_IP netmask $NETMASK up

echo "[*] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null

echo "[*] Flushing old iptables rules..."
sudo iptables -F
sudo iptables -t nat -F

echo "[*] Preparing hostapd control socket dir..."
sudo mkdir -p /var/run/hostapd
sudo chown root:root /var/run/hostapd

echo "[*] Starting hostapd..."
sudo hostapd -B $HOSTAPD_CONF

echo "[*] Starting dnsmasq..."
sudo dnsmasq -C $DNSMASQ_CONF

echo "[*] Setting up NAT and forwarding rules..."
sudo iptables -t nat -A POSTROUTING -o $INTERNET_IFACE -j MASQUERADE
sudo iptables -A FORWARD -i $WIFI_IFACE -o $INTERNET_IFACE -j ACCEPT
sudo iptables -A FORWARD -i $INTERNET_IFACE -o $WIFI_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# === Captive portal redirect (force all HTTP -> Apache) ===
sudo iptables -t nat -A PREROUTING -i $WIFI_IFACE -p tcp --dport 80 -j DNAT --to-destination $AP_IP:80

echo ""
echo "[*] Captive Portal started successfully!"
echo "   🔹 SSID        : $SSID"
echo "   🔹 WiFi iface  : $WIFI_IFACE"
echo "   🔹 Internet IF : $INTERNET_IFACE"
echo "   🔹 Portal IP   : $AP_IP"
