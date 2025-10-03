<?php
use Dotenv\Dotenv;

require __DIR__ . '/../vendor/autoload.php';

// Load environment variables (.env)
$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->load();
