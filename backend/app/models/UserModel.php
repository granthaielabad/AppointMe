<?php
namespace App\Models;

class UserModel extends BaseModel
{
    protected string $table = 'users';

    public function find(int $id): ?array
    {
        $rows = $this->fetchAll("SELECT * FROM {$this->table} WHERE id = ?", [$id]);
        return $rows[0] ?? null;
    }
}
