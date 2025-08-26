#!/bin/bash
set -e

echo "[*] Installing dependencies..."
sudo apt update

sudo apt install dos2unix
find . -type f \( -name "*.sh" -o -name "*.php" -o -name "*.conf" \) -exec dos2unix {} \;

sudo apt install -y apache2 php libapache2-mod-php sqlite3 php-sqlite3 php-mysqli dnsmasq hostapd net-tools 



echo "[*] Preparing portal directory..."
sudo mkdir -p /var/www/portal
sudo cp -r portal/* /var/www/portal/
sudo dos2unix /var/www/portal/*.php
sudo chown -R www-data:www-data /var/www/portal
sudo chmod -R 755 /var/www/portal

echo "[*] Creating secure DB location..."
sudo mkdir -p /var/www/secure
sudo touch /var/www/secure/portal.db
sudo chown www-data:www-data /var/www/secure/portal.db
sudo chmod 660 /var/www/secure/portal.db

echo "[*] Giving www-data passwordless sudo for iptables (for testing only)..."
SUDOERS_FILE="/etc/sudoers.d/www-data-iptables"
sudo bash -c "echo 'www-data ALL=(ALL) NOPASSWD: /sbin/iptables' > $SUDOERS_FILE"
sudo chmod 440 $SUDOERS_FILE

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
        FallbackResource /login.php
    </Directory>

    # Protect DB file
    <Files "/var/www/secure/portal.db">
        Require all denied
    </Files>
</VirtualHost>
EOF

# List all enabled sites
ls /etc/apache2/sites-enabled/

# Disable all
sudo a2dissite '*' || true

sudo a2ensite portal.conf
sudo systemctl reload apache2

sudo chown -R www-data:www-data /var/www/secure

# Give proper read/write permissions
sudo chmod 770 /var/www/secure
sudo chmod 660 /var/www/secure/portal.db

echo "[*] Setup complete!"
echo "   🔹 Portal folder: /var/www/portal"
echo "   🔹 Secure DB: /var/www/secure/portal.db"
echo "   🔹 Apache site enabled: portal.conf"
echo "[*] Captive Portal is Actively running"




