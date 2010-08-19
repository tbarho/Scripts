<?php


// Browsing to this page adds a database called TestScript

$databaseName = $_POST['DBName'];

echo (shell_exec("mysqladmin -u root -proot create $databaseName"));

echo "Thanks, I added a DB called " . $databaseName . ".";