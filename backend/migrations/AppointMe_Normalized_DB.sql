-- ================================
-- ROLES (only for employees/admins)
-- ================================
CREATE TABLE tbl_roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE, -- 'employee', 'accountant', 'hairstylist', 'pedicurist', 'admin'
  description VARCHAR(255)
);

INSERT INTO tbl_roles (name, description) VALUES
('admin','System Administrator'),
('employee','General Employee'),
('accountant','Handles payroll and finances'),
('hairstylist','Provides hair-related services'),
('pedicurist','Provides pedicure services');

-- ================================
-- USERS (employees/admins only)
-- ================================
CREATE TABLE tbl_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone_no VARCHAR(15),
  is_verified TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

-- Mapping users -> roles
CREATE TABLE tbl_user_roles (
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  PRIMARY KEY(user_id, role_id),
  FOREIGN KEY (user_id) REFERENCES tbl_users(id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES tbl_roles(id) ON DELETE CASCADE
);

-- ================================
-- EMPLOYEES
-- ================================
CREATE TABLE tbl_employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  employee_code VARCHAR(50) UNIQUE,
  hire_date DATE,
  position VARCHAR(100),
  salary_base DECIMAL(12,2) DEFAULT 0.00,
  status ENUM('active','inactive','terminated') DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES tbl_users(id) ON DELETE CASCADE
);

-- ================================
-- GUESTS (for bookings)
-- ================================
CREATE TABLE tbl_guests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone_no VARCHAR(15) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================================
-- SERVICE CATEGORIES
-- ================================
CREATE TABLE tbl_service_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT
);

INSERT INTO tbl_service_categories (name, description) VALUES
('Hair Services','Haircut, styling, coloring'),
('Nail Services','Manicure, pedicure, nail art'),
('Skin Care','Facials, treatments');

-- ================================
-- SERVICES
-- ================================
CREATE TABLE tbl_services (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT,
  name VARCHAR(150) NOT NULL,
  duration_minutes INT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES tbl_service_categories(id) ON DELETE SET NULL
);

INSERT INTO tbl_services (category_id, name, duration_minutes, price) VALUES
(1,'Basic Haircut',30,150.00),
(1,'Hair Coloring',120,800.00),
(2,'Classic Pedicure',45,200.00),
(3,'Facial Treatment',60,500.00);

-- ================================
-- EMPLOYEES -> SERVICES (many-to-many)
-- ================================
CREATE TABLE tbl_service_providers (
  service_id INT NOT NULL,
  employee_id INT NOT NULL,
  PRIMARY KEY(service_id, employee_id),
  FOREIGN KEY (service_id) REFERENCES tbl_services(id) ON DELETE CASCADE,
  FOREIGN KEY (employee_id) REFERENCES tbl_employees(id) ON DELETE CASCADE
);

-- ================================
-- APPOINTMENT STATUSES
-- ================================
CREATE TABLE tbl_appointment_statuses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) UNIQUE,
  label VARCHAR(50)
);

INSERT INTO tbl_appointment_statuses (code,label) VALUES
('pending','Pending'),
('accepted','Accepted'),
('rejected','Rejected'),
('completed','Completed'),
('cancelled','Cancelled');

-- ================================
-- APPOINTMENTS
-- ================================
CREATE TABLE tbl_appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  guest_id INT NOT NULL,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  duration_minutes INT NOT NULL,
  employee_id INT NULL,
  note TEXT,
  status_id INT NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (guest_id) REFERENCES tbl_guests(id) ON DELETE CASCADE,
  FOREIGN KEY (employee_id) REFERENCES tbl_employees(id) ON DELETE SET NULL,
  FOREIGN KEY (status_id) REFERENCES tbl_appointment_statuses(id) ON DELETE RESTRICT
);

-- ================================
-- APPOINTMENT ITEMS
-- ================================
CREATE TABLE tbl_appointment_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  service_id INT NOT NULL,
  price_at_booking DECIMAL(12,2) NOT NULL,
  duration_minutes INT NOT NULL,
  FOREIGN KEY (appointment_id) REFERENCES tbl_appointments(id) ON DELETE CASCADE,
  FOREIGN KEY (service_id) REFERENCES tbl_services(id) ON DELETE RESTRICT
);

-- ================================
-- INVOICES
-- ================================
CREATE TABLE tbl_invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NULL UNIQUE,
  guest_id INT NOT NULL,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  subtotal DECIMAL(12,2) NOT NULL,
  tax DECIMAL(12,2) DEFAULT 0.00,
  discount DECIMAL(12,2) DEFAULT 0.00,
  total DECIMAL(12,2) NOT NULL,
  status ENUM('unpaid','paid','refunded') DEFAULT 'unpaid',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id) REFERENCES tbl_appointments(id) ON DELETE SET NULL,
  FOREIGN KEY (guest_id) REFERENCES tbl_guests(id) ON DELETE CASCADE
);

-- ================================
-- INVOICE ITEMS
-- ================================
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

-- ================================
-- PAYMENTS (GCash only)
-- ================================
CREATE TABLE tbl_payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT NOT NULL,
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  method ENUM('gcash') DEFAULT 'gcash',
  amount DECIMAL(12,2) NOT NULL,
  reference VARCHAR(255) NOT NULL, -- GCash Ref #
  FOREIGN KEY (invoice_id) REFERENCES tbl_invoices(id) ON DELETE CASCADE
);

-- ================================
-- ATTENDANCE
-- ================================
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

-- ================================
-- LEAVES
-- ================================
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

-- ================================
-- PAYROLLS
-- ================================
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

CREATE TABLE tbl_payroll_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  payroll_id INT NOT NULL,
  description VARCHAR(255),
  amount DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (payroll_id) REFERENCES tbl_payrolls(id) ON DELETE CASCADE
);

-- ================================
-- INQUIRIES
-- ================================
CREATE TABLE tbl_inquiries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150),
  email VARCHAR(255),
  subject VARCHAR(255),
  message TEXT,
  status ENUM('inbox','deleted') DEFAULT 'inbox',
  received_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================================
-- SITE SETTINGS
-- ================================
CREATE TABLE tbl_site_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  key_name VARCHAR(100) UNIQUE,
  value TEXT
);

INSERT INTO tbl_site_settings (key_name, value) VALUES
('site_name','8th Avenue Salon'),
('contact_email','info@8avenuesalon.com'),
('contact_phone','09171234567'),
('about_us','Welcome to 8th Avenue Salon, your hub for beauty and relaxation.');

-- ================================
-- AUDIT LOGS
-- ================================
CREATE TABLE tbl_audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(255),
  meta TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
