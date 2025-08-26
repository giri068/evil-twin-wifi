#!/bin/bash
set -e

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php sqlite3 dnsmasq hostapd

echo "[*] Preparing portal directory..."
sudo mkdir -p /var/www/portal
sudo cp -r portal/* /var/www/portal/
sudo chown -R www-data:www-data /var/www/portal

echo "[*] Creating secure DB location..."
sudo mkdir -p /var/www/secure
sudo touch /var/www/secure/portal.db
sudo chown www-data:www-data /var/www/secure/portal.db
sudo chmod 660 /var/www/secure/portal.db

echo "[*] Configuring Apache..."
PORTAL_CONF="/etc/apache2/sites-available/portal.conf"
sudo bash -c "cat > $PORTAL_CONF" <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/portal
    <Directory /var/www/portal>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex login.php
    </Directory>

    # Protect DB file
    <Files "portal.db">
        Require all denied
    </Files>
</VirtualHost>
EOF

sudo a2dissite 000-default.conf
sudo a2ensite portal.conf
sudo systemctl reload apache2

echo "[*] Setup done. Apache serving portal!"
