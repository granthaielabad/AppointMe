<?php
namespace App\Services;

use App\Models\AppointmentModel;

class CalendarService {
    private $appointmentModel;

    public function __construct() {
        $this->appointmentModel = new AppointmentModel();
    }

    public function isSlotAvailable($providerId, $date, $startTime, $endTime) {
        $appointments = $this->appointmentModel->getAppointmentsByProviderAndDate($providerId, $date);

        foreach ($appointments as $appt) {
            if (
                ($startTime < $appt['end_time']) &&
                ($endTime > $appt['start_time'])
            ) {
                return false; // overlap
            }
        }
        return true;
    }

    public function getProviderSchedule($providerId, $date) {
        return $this->appointmentModel->getAppointmentsByProviderAndDate($providerId, $date);
    }
}
