<?php


// Browsing to this page adds a database called TestScript

$databaseName = $_POST['DBName'];

echo (shell_exec('"mysql -e"DROP DATABASE IF EXISTS '.$databaseName.';" -u root -p"root"'));

echo "Thanks, I added a DB called " . $databaseName . ".";