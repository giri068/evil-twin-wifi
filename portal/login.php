<?php
session_start();
$db = new SQLite3('/var/www/secure/portal.db');

// Ensure sessions table exists
$db->exec("CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    ip TEXT NOT NULL,
    mac TEXT,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active INTEGER DEFAULT 1,
    expiry INTEGER
)");

// Ensure users table exists
$db->exec("CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
)");

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user = trim($_POST['username'] ?? '');
    $pass = trim($_POST['password'] ?? '');
    $client_ip = $_SERVER['REMOTE_ADDR'];

    // Block empty login
    if ($user === '' || $pass === '') {
        $error = "Username and password cannot be empty!";
    } else {
        // Get MAC from ARP
        $arp = shell_exec("arp -n $client_ip | awk 'NR==2 {print \$3}'");
        $client_mac = trim($arp);

        // Check if user exists
        $stmt = $db->prepare("SELECT * FROM users WHERE username = :u");
        $stmt->bindValue(':u', $user, SQLITE3_TEXT);
        $row = $stmt->execute()->fetchArray(SQLITE3_ASSOC);

        if ($row) {
            // User exists → check password
            if ($row['password'] === $pass) {
                // Correct → login
            } else {
                $error = "Invalid username or password!";
            }
        } else {
            // Do not auto-create accounts unless you want registration
            $error = "User does not exist!";
        }

        // If login successful
        if (!isset($error)) {
            $_SESSION['user'] = $user;

            // Remove old sessions for same IP/MAC
            $stmt = $db->prepare("DELETE FROM sessions WHERE ip = :ip OR mac = :mac");
            $stmt->bindValue(':ip', $client_ip, SQLITE3_TEXT);
            $stmt->bindValue(':mac', $client_mac, SQLITE3_TEXT);
            $stmt->execute();

            // Insert new session with expiry (1h)
            $expiry = time() + 3600;
            $stmt = $db->prepare("INSERT INTO sessions (username, ip, mac, active, expiry)
                                  VALUES (:u, :ip, :mac, 1, :exp)");
            $stmt->bindValue(':u', $user, SQLITE3_TEXT);
            $stmt->bindValue(':ip', $client_ip, SQLITE3_TEXT);
            $stmt->bindValue(':mac', $client_mac, SQLITE3_TEXT);
            $stmt->bindValue(':exp', $expiry, SQLITE3_INTEGER);
            $stmt->execute();

            // Whitelist client in iptables
            shell_exec("sudo iptables -t nat -I PREROUTING -s $client_ip -j RETURN");

            header("Location: success.php");
            exit();
        }
    }
}
?>


<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>University Wi-Fi Login</title>
  <style>
    body {
      margin: 0;
      font-family: "Segoe UI", Helvetica, Arial, sans-serif;
      background-color: #f0f0f0;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    .login-card {
      background: #fff;
      padding: 2rem;
      border-radius: 12px;
      width: 100%;
      max-width: 400px;
      box-shadow: 0 8px 25px rgba(0,0,0,0.2);
      text-align: center;
    }
    .login-card img {
      height: 80px;
      margin-bottom: 1rem;
    }
    .login-card h2 {
      margin: 0 0 1.5rem 0;
      color: #333;
    }
    .input-group {
      margin-bottom: 1rem;
      text-align: left;
    }
    .input-group label {
      display: block;
      font-size: 0.9rem;
      margin-bottom: 0.3rem;
      color: #444;
    }
    .input-group input {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #ccc;
      border-radius: 6px;
      font-size: 1rem;
      box-sizing: border-box;
    }
    .input-group input:focus {
      border-color: #2a5298;
      outline: none;
      box-shadow: 0 0 4px rgba(42,82,152,0.4);
    }
    .btn {
      display: block;
      width: 100%;
      padding: 0.75rem;
      background: #2a5298;
      color: #fff;
      font-size: 1rem;
      font-weight: bold;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      transition: background 0.3s;
    }
    .btn:hover {
      background: #1e3c72;
    }
    .error {
      color: #d8000c;
      margin-bottom: 1rem;
      font-size: 0.9rem;
    }
    @media (max-width: 480px) {
      .login-card {
        margin: 1rem;
        padding: 1.5rem;
      }
    }
  </style>
</head>
<body>
  <div class="login-card">
    <img src="wifi-logo.jpg" alt="Logo">
    <h2>Login To Access The Internet</h2>
    <?php if(isset($error)) echo "<p class='error'>$error</p>"; ?>
    <form method="POST">
      <div class="input-group">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" required />
      </div>
      <div class="input-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" required />
      </div>
      <button type="submit" class="btn">Login</button>
    </form>
  </div>
</body>
</html>