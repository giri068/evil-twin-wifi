<?php
session_start();
if(!isset($_SESSION['user'])) { header("Location: login.php"); exit(); }
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Authentication Successful</title>
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
    .success-card {
      background: #fff;
      padding: 2rem;
      border-radius: 12px;
      width: 100%;
      max-width: 450px;
      box-shadow: 0 8px 25px rgba(0,0,0,0.2);
      text-align: center;
    }
    .success-card img {
      height: 80px;
      margin-bottom: 1rem;
    }
    .success-card h2 {
      margin: 0 0 1rem 0;
      color: #28a745;
    }
    .success-card p {
      font-size: 1rem;
      margin-bottom: 1.5rem;
      color: #333;
    }
    .btn {
      display: block;
      width: 100%;
      padding: 0.75rem;
      font-size: 1rem;
      font-weight: bold;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      margin-top: 0.8rem;
      transition: background 0.3s;
    }
    .btn.continue {
      background: #2a5298;
      color: #fff;
    }
    .btn.continue:hover {
      background: #1e3c72;
    }
    .btn.logout {
      background: #d9534f;
      color: #fff;
    }
    .btn.logout:hover {
      background: #c9302c;
    }
    @media (max-width: 480px) {
      .success-card {
        margin: 1rem;
        padding: 1.5rem;
      }
    }
  </style>
</head>
<body>
  <div class="success-card">
    <img src="wifi-logo.jpg" alt="Logo" />
    <h2>Authentication Successful </h2>
    <p>Welcome <b><?php echo $_SESSION['user']; ?></b>, you are now connected to the internet.</p>
    
    <a href="http://www.gstatic.com/generate_204" target="_blank">
      <button class="btn continue">Continue Browsing</button>
    </a>

    <form action="logout.php" method="POST">
      <button type="submit" class="btn logout">Logout</button>
    </form>
  </div>
</body>
</html>
