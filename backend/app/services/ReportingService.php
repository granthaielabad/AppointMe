<?php
namespace App\Services;

use App\Models\AppointmentModel;
use App\Models\InvoiceModel;
use App\Models\PayrollModel;

class ReportingService {
    private $appointmentModel;
    private $invoiceModel;
    private $payrollModel;

    public function __construct() {
        $this->appointmentModel = new AppointmentModel();
        $this->invoiceModel = new InvoiceModel();
        $this->payrollModel = new PayrollModel();
    }

    public function generateSalesReport($startDate, $endDate) {
        return $this->invoiceModel->getInvoicesBetweenDates($startDate, $endDate);
    }

    public function generateAppointmentReport($startDate, $endDate) {
        return $this->appointmentModel->getAppointmentsBetweenDates($startDate, $endDate);
    }

    public function generatePayrollReport($month) {
        return $this->payrollModel->getPayrollByMonth($month);
    }
}
