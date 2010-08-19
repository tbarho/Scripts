<?php


// Browsing to this page adds a database called TestScript

$databaseName = "TestScript";

echo (shell_exec("mysqladmin -u root -proot create $databaseName"));