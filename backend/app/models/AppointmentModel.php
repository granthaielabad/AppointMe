<?php
namespace App\Models;


class AppointmentModel extends BaseModel {
protected $table = 'appointments';


public function create($data){
$sql = "INSERT INTO appointments (customer_id, appointment_date, appointment_time, duration_minutes, employee_id, note) VALUES (?,?,?,?,?,?)";
$this->query($sql, [$data['customer_id'],$data['appointment_date'],$data['appointment_time'],$data['duration_minutes'],$data['employee_id'],$data['note']]);
return $this->db->lastInsertId();
}


public function isSlotTaken($employeeId, $date, $time, $duration){
$sql = "SELECT COUNT(*) as cnt FROM appointments WHERE employee_id = ? AND appointment_date = ? AND appointment_time = ? AND status NOT IN ('cancelled','completed')";
$stmt = $this->query($sql, [$employeeId, $date, $time]);
$row = $stmt->fetch();
return $row['cnt'] > 0;
}


public function reschedule($id, $data){
$sql = "UPDATE appointments SET appointment_date=?, appointment_time=?, employee_id=? WHERE id=?";
$this->query($sql, [$data['appointment_date'],$data['appointment_time'],$data['employee_id'],$id]);
}


public function cancel($id){
$sql = "UPDATE appointments SET status='cancelled' WHERE id=?";
$this->query($sql, [$id]);
}


public function findByCustomer($customerId){
$stmt = $this->query("SELECT * FROM appointments WHERE customer_id=? ORDER BY appointment_date DESC", [$customerId]);
return $stmt->fetchAll();
}
}