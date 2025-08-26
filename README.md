
---

````markdown
# Evil Twin Wi-Fi Attack (Educational Simulation)

This project demonstrates how an **Evil Twin Wi-Fi attack** works by simulating a fake Access Point with a captive portal.  

⚠️ For **educational purposes only** – do not use against networks you don’t own or have permission to test.

---

## Features
- Fake Wi-Fi Access Point with custom SSID  
- Captive portal login page (mobile + desktop friendly)  
- Credentials stored in local SQLite database  
- Session tracking (IP, MAC, login time, active status)  
- Monitoring script to view connected users in real time  
- Start/Stop scripts for easy management  

---

## Before You Begin
Make sure the following requirements are met:

1. **Linux system**  
   Tested on Ubuntu 22.04/20.04. Debian-based systems should also work.  

2. **USB Wi-Fi adapter with AP mode support**  
   Check if your adapter supports AP mode:  
   ```bash
   iw list | grep -A 10 "Supported interface modes"
````

Look for `AP` in the list.

3. **Active Internet connection** on another interface

   * Example:

     * `eth0` → Internet interface (wired)
     * `wlan0` → Wireless adapter for fake AP
   * If your interface names differ (e.g., `wlp3s0`, `ens33`), update them in `start.sh`.

4. **Root privileges**
   All scripts require `sudo`.

5. **Dependencies**: Apache, PHP, SQLite3, hostapd, dnsmasq
   Install automatically using:

   ```bash
   sudo ./setup.sh
   ```

6. **Disable NetworkManager for the Wi-Fi adapter**
   Prevents conflicts with hostapd:

   ```bash
   nmcli dev set wlan0 managed no
   ```

---

## Setup

Clone the repository and set permissions:

```bash
git clone https://github.com/yourname/evil-twin-wifi.git
cd evil-twin-wifi
chmod +x setup.sh start.sh stop.sh monitor.sh
sudo ./setup.sh
```

---

## Usage

Start fake AP and captive portal:

```bash
sudo ./start.sh
```

Stop and restore:

```bash
sudo ./stop.sh
```

Monitor connected users:

```bash
sudo ./monitor.sh
```

---

## Project Structure

```
wifi-evil-twin/
│── start.sh         # Start AP + captive portal
│── stop.sh          # Stop services + cleanup
│── monitor.sh       # View active sessions
│── setup.sh         # Install dependencies + configure Apache/DB
│── dnsmasq.conf     # DHCP/DNS config
│── hostapd.conf     # AP config (SSID injected at runtime)
│── portals/         # Captive portal (login.php, success.php, logout.php, assets)
```

---

## Disclaimer

This repository is for **educational and research purposes only**.
The author is not responsible for misuse. Use only in controlled lab environments.

```

---

This will look perfectly aligned in GitHub with proper sections, code blocks, and lists.  

Do you also want me to add a **“Troubleshooting”** section (for errors like `dnsmasq: failed to bind` or `hostapd: nl80211 not found`) so that beginners can solve issues quickly?
```
