<?php
session_start();
$client_ip = $_SERVER['REMOTE_ADDR'];
$db = new SQLite3('/var/www/secure/portal.db');

// Mark session inactive
$db->exec("UPDATE sessions SET active=0 WHERE ip='$client_ip'");

// Remove whitelist rule
shell_exec("sudo iptables -t nat -D PREROUTING -s $client_ip -j RETURN");

session_destroy();
header("Location: login.php");
exit();
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Firewall Authentication Logout</title>
<style>
    html, body {
        height: 100%;
        margin: 0;
    }
    body {
        display: flex;
        justify-content: center; /* horizontal center */
        align-items: center;     /* vertical center */
        background-color: #f0f0f0; /* optional: light background */
       /* font-family: Arial, sans-serif;*/
    }
    h3 {
        text-align: center;
        color: #333;
    }
</style>
</head>
<body>
    <h3>You have successfully logged out</h3>
</body>
</html>
