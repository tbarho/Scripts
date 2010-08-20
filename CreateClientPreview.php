<?php


// Browsing to this page adds a database called TestScript

$previewName = $_POST['PreviewName'];

echo (shell_exec('./create_client_preview.sh '.$previewName));