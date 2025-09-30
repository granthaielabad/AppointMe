-- Roles
CREATE TABLE tbl_roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE, -- 'customer', 'employee', 'accountant', 'hairstylist', 'pedicurist', 'admin'
  description VARCHAR(255)
);

-- Users (base identity)
CREATE TABLE tbl_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE, -- email or student number equivalent
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone_no VARCHAR(11),
  is_verified TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

-- Mapping users -> roles (many-to-many allows multiple roles)
CREATE TABLE tbl_user_roles (
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  PRIMARY KEY(user_id, role_id),
  FOREIGN KEY (user_id) REFERENCES tbl_users(id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES tbl_roles(id) ON DELETE CASCADE
);

-- Employees (profiles tied to users)
CREATE TABLE tbl_employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  employee_code VARCHAR(50) UNIQUE,
  hire_date DATE,
  position VARCHAR(100), -- free text, also can be derived from role
  salary_base DECIMAL(12,2) DEFAULT 0.00,
  status ENUM('active','inactive','terminated') DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES tbl_users(id) ON DELETE CASCADE
);

-- Service categories
CREATE TABLE tbl_service_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT
);

-- Services
CREATE TABLE tbl_services (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT,
  name VARCHAR(150) NOT NULL,
  duration_minutes INT NOT NULL, -- for scheduling
  price DECIMAL(12,2) NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES tbl_service_categories(id) ON DELETE SET NULL
);

-- Many-to-many: which employees provide which services
CREATE TABLE tbl_service_providers (
  service_id INT NOT NULL,
  employee_id INT NOT NULL,
  PRIMARY KEY(service_id, employee_id),
  FOREIGN KEY (service_id) REFERENCES tbl_services(id) ON DELETE CASCADE,
  FOREIGN KEY (employee_id) REFERENCES tbl_employees(id) ON DELETE CASCADE
);

-- Appointment statuses lookup
CREATE TABLE tbl_appointment_statuses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) UNIQUE, -- pending, accepted, rejected, completed, cancelled
  label VARCHAR(50)
);

INSERT INTO tbl_appointment_statuses (code,label) VALUES
('pending','Pending'), ('accepted','Accepted'), ('rejected','Rejected'),
('completed','Completed'), ('cancelled','Cancelled');

-- Appointments (one row per booking)
CREATE TABLE tbl_appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL, -- references users.id
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL, -- start time
  duration_minutes INT NOT NULL, -- total duration (sum of service durations)
  employee_id INT NULL, -- optional requested employee
  note TEXT,
  status_id INT NOT NULL DEFAULT 1, -- pending by default
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES tbl_users(id) ON DELETE CASCADE,
  FOREIGN KEY (employee_id) REFERENCES tbl_employees(id) ON DELETE SET NULL,
  FOREIGN KEY (status_id) REFERENCES tbl_appointment_statuses(id) ON DELETE RESTRICT
);

-- Appointment items (services per appointment) -> normalization
CREATE TABLE tbl_appointment_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  service_id INT NOT NULL,
  price_at_booking DECIMAL(12,2) NOT NULL,
  duration_minutes INT NOT NULL,
  FOREIGN KEY (appointment_id) REFERENCES tbl_appointments(id) ON DELETE CASCADE,
  FOREIGN KEY (service_id) REFERENCES tbl_services(id) ON DELETE RESTRICT
);

-- Invoices
CREATE TABLE tbl_invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NULL UNIQUE, -- optionally linked to an appointment
  customer_id INT NOT NULL,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  subtotal DECIMAL(12,2) NOT NULL,
  tax DECIMAL(12,2) DEFAULT 0.00,
  discount DECIMAL(12,2) DEFAULT 0.00,
  total DECIMAL(12,2) NOT NULL,
  status ENUM('unpaid','paid','refunded') DEFAULT 'unpaid',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id) REFERENCES tbl_appointments(id) ON DELETE SET NULL,
  FOREIGN KEY (customer_id) REFERENCES tbl_users(id) ON DELETE CASCADE
);

-- Invoice items
CREATE TABLE tbl_invoice_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT NOT NULL,
  service_id INT NULL,
  description VARCHAR(255),
  unit_price DECIMAL(12,2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  line_total DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (invoice_id) REFERENCES tbl_invoices(id) ON DELETE CASCADE,
  FOREIGN KEY (service_id) REFERENCES tbl_services(id) ON DELETE SET NULL
);

-- Payments (for invoices)
CREATE TABLE tbl_payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT NOT NULL,
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  method VARCHAR(50), -- 'cash','card','on-delivery'
  amount DECIMAL(12,2) NOT NULL,
  reference VARCHAR(255),
  FOREIGN KEY (invoice_id) REFERENCES tbl_invoices(id) ON DELETE CASCADE
);

-- Attendance
CREATE TABLE tbl_attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  date DATE NOT NULL,
  check_in TIME,
  check_out TIME,
  status ENUM('present','absent','on_leave') DEFAULT 'present',
  FOREIGN KEY (employee_id) REFERENCES tbl_employees(id) ON DELETE CASCADE,
  UNIQUE(employee_id, date)
);

-- Leaves
CREATE TABLE tbl_leaves (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  leave_type VARCHAR(100),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason TEXT,
  status ENUM('pending','approved','rejected') DEFAULT 'pending',
  requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  reviewed_at DATETIME NULL,
  reviewer_id INT NULL,
  FOREIGN KEY (employee_id) REFERENCES tbl_employees(id) ON DELETE CASCADE,
  FOREIGN KEY (reviewer_id) REFERENCES tbl_users(id) ON DELETE SET NULL
);

-- Payrolls (monthly/periodic)
CREATE TABLE tbl_payrolls (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  gross_pay DECIMAL(12,2) NOT NULL,
  net_pay DECIMAL(12,2) NOT NULL,
  deductions DECIMAL(12,2) DEFAULT 0.00,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES tbl_employees(id) ON DELETE CASCADE,
  UNIQUE(employee_id, period_start, period_end)
);

-- Payroll items (breakdown)
CREATE TABLE tbl_payroll_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  payroll_id INT NOT NULL,
  description VARCHAR(255),
  amount DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (payroll_id) REFERENCES tbl_payrolls(id) ON DELETE CASCADE
);

-- Inquiries (contact form)
CREATE TABLE tbl_inquiries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150),
  email VARCHAR(255),
  subject VARCHAR(255),
  message TEXT,
  status ENUM('inbox','deleted') DEFAULT 'inbox',
  received_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Site settings (About, Contact)
CREATE TABLE tbl_site_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  key_name VARCHAR(100) UNIQUE,
  value TEXT
);

-- Temp bookings (guest prefilled booking persisted until signup/verification)
CREATE TABLE tbl_temp_bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  token VARCHAR(128) NOT NULL UNIQUE, -- used to associate booking with email session
  service_ids TEXT, -- JSON array or CSV of service IDs
  employee_id INT NULL,
  appointment_date DATE,
  appointment_time TIME,
  note TEXT,
  email VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Verification tokens (email verification, password reset)
CREATE TABLE tbl_verification_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  token VARCHAR(128) NOT NULL UNIQUE,
  type ENUM('email_verify','password_reset') NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  used TINYINT(1) DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES tbl_users(id) ON DELETE CASCADE
);

-- Audit logs (optional)
CREATE TABLE tbl_audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(255),
  meta TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
