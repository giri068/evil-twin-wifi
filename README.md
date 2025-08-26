Evil Twin Wi-Fi Attack (Educational Simulation)

This project demonstrates how an Evil Twin Wi-Fi attack works by simulating a fake Access Point with a captive portal.
⚠️ Educational purposes only – do not use against networks you don’t own or have permission to test.

Features

Fake Wi-Fi Access Point with custom SSID

Captive portal login page (mobile + desktop friendly)

Credentials stored in local SQLite database

Session tracking (IP, MAC, login time, active status)

Monitoring script to view connected users in real time

Start/Stop scripts for easy management

Before You Begin ✅

Make sure the following are ready before running the project:

Linux system (tested on Ubuntu 22.04/20.04, Debian-based distros should also work).

USB Wi-Fi adapter that supports Access Point (AP) mode and packet injection.

You can check if your adapter supports AP mode:

iw list | grep -A 10 "Supported interface modes"


Look for AP in the list.

Active Internet connection on your host machine (usually via Ethernet).

Example:

eth0 → Internet interface (wired).

wlan0 → Wireless adapter used for fake AP.

If your interface names differ (like wlp3s0 or ens33), update them in start.sh.

Root privileges are required (use sudo when running scripts).

Apache, PHP, SQLite3, hostapd, dnsmasq must be installed.

Setup script will install automatically:

sudo ./setup.sh


Make sure NetworkManager is not controlling your Wi-Fi adapter (otherwise hostapd fails).
Disable it for the adapter:

nmcli dev set wlan0 managed no

Setup

Clone the repo and set up dependencies:

git clone https://github.com/giri068/evil-twin-wifi.git
cd evil-twin-wifi
chmod +x setup.sh start.sh stop.sh monitor.sh
sudo ./setup.sh

Usage

Start the fake AP and captive portal:

sudo ./start.sh


Stop everything and restore:

sudo ./stop.sh


Monitor connected users in real-time:

sudo ./monitor.sh

Project Structure
wifi-evil-twin/
│── start.sh         # Start AP + captive portal
│── stop.sh          # Stop services + clean up
│── monitor.sh       # View active sessions
│── setup.sh         # Install dependencies + configure Apache/DB
│── dnsmasq.conf     # DHCP/DNS config
│── hostapd.conf     # AP config (SSID injected at runtime)
│── portals/         # Captive portal (login.php, success.php, logout.php, assets)

Disclaimer

This repository is for educational and research purposes only.
The author is not responsible for any misuse. Use only in controlled lab environments.
