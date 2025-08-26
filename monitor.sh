#!/bin/bash
# Monitor Evil Twin Clients dynamically

# === Configurable paths ===
DB="/var/www/secure/portal.db"
LEASES="/var/lib/misc/dnsmasq.leases"

# === Detect Wi-Fi interface dynamically ===
WIFI_IFACE=$(iw dev | awk '$1=="Interface"{print $2}' | head -n1)
if [ -z "$WIFI_IFACE" ]; then
    read -p "Enter your WiFi interface (e.g., wlan0, wlp2s0): " WIFI_IFACE
fi

echo "=== WiFi Captive Portal Monitor ==="
echo "Time: $(date)"
echo "------------------------------------------------------------"
printf "%-15s %-17s %-12s %-10s %-7s %-9s %-10s\n" "IP" "MAC" "User" "Status" "Signal" "Data_Used" "Conn_Time"
echo "------------------------------------------------------------"

# Loop through dnsmasq leases
if [ ! -f "$LEASES" ]; then
    echo "[!] dnsmasq leases file not found: $LEASES"
    exit 1
fi

while read -r ts mac ip host clientid; do
    # username lookup from SQLite
    if [ -f "$DB" ]; then
        user=$(sqlite3 "$DB" "SELECT username FROM sessions WHERE ip='$ip' AND active=1;")
    else
        user=""
    fi

    if [ -z "$user" ]; then
        user="(unknown)"
        status="IDLE"
    else
        status="ACTIVE"
    fi

    # signal strength from hostapd
    signal=$(sudo hostapd_cli -i "$WIFI_IFACE" all_sta 2>/dev/null | grep -A10 "$mac" | grep signal | awk '{print $2}')
    signal="${signal:-?}"  # fallback if empty

    # connection time
    conn_time=$(( $(date +%s) - ts ))
    conn_time="${conn_time}s"

    printf "%-15s %-17s %-12s %-10s %-7s %-9s %-10s\n" "$ip" "$mac" "$user" "$status" "$signal" "0B" "$conn_time"
done < "$LEASES"

echo "------------------------------------------------------------"
echo "Tip: Run with: watch -n 5 ./monitor.sh"
