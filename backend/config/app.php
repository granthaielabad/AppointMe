<?php
return [
    'name' => 'AppointMe',
    'env' => $_ENV['APP_ENV'] ?? 'local',
    'debug' => $_ENV['APP_DEBUG'] ?? true,
    'url' => $_ENV['APP_URL'] ?? 'http://localhost:5000',
    'timezone' => 'Asia/Manila',
];
