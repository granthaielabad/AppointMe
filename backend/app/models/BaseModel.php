<?php
namespace App\Models;

use PDO;
use PDOException;

abstract class BaseModel
{
    protected static PDO $db; // PDO - represents a connection between PHP and a database server

    public static function setConnection(PDO $connection): void
    {
        self::$db = $connection;
    }

    /** Quick helper for SELECT queries */
    protected function fetchAll(string $sql, array $params = []): array
    {
        $stmt = self::$db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /** Quick helper for INSERT/UPDATE/DELETE */
    protected function execute(string $sql, array $params = []): bool
    {
        $stmt = self::$db->prepare($sql);
        return $stmt->execute($params);
    }

    /** Return last insert id */
    protected function lastInsertId(): string
    {
        return self::$db->lastInsertId();
    }
}
