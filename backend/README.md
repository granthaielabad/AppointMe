## Backend Architecture - directory structure and modules

/backend
  /app
    /controllers
      AuthController.php
      BookingController.php
      AppointmentController.php
      ServiceController.php
      EmployeeController.php
      PayrollController.php
      InvoiceController.php
      PaymentController.php
      AdminController.php
      InquiryController.php
      HomeController.php
    /models
      BaseModel.php
      UserModel.php
      RoleModel.php
      EmployeeModel.php
      ServiceModel.php
      ServiceCategoryModel.php
      ServiceProviderModel.php
      AppointmentModel.php
      AppointmentItemModel.php
      InvoiceModel.php
      InvoiceItemModel.php
      PaymentModel.php
      TempBookingModel.php
      VerificationTokenModel.php
      PayrollModel.php
      PayrollItemModel.php
      AttendanceModel.php
      LeaveModel.php
      InquiryModel.php
      SiteSettingModel.php
    /views
      /templates
        header.php
        footer.php
      /public
      /customer
      /employee
      /admin
    /middlewares
      AuthMiddleware.php
      RbacMiddleware.php
      CsrfMiddleware.php
      RateLimitMiddleware.php
    /services
      MailService.php           // PHPMailer wrapper
      PDFService.php            // DOMPDF wrapper example
      CalendarService.php
      ReportingService.php
      AuditService.php
    /helpers
      Helpers.php               // utility functions
      Validator.php
      Response.php              // consistent API response helpers
  /config
    app.php                     // app-level config (env, debug)
    database.php                // DB credentials and PDO wrapper
    mail.php                    // SMTP config
    roles.php                   // roles and permission mapping
  /public
    index.php                   // front controller
    .htaccess                   // rewrite rules
    /assets
      /css
      /js
      /images
  /migrations                   // SQL files for table creation
  /seeders                      // seed data PHP scripts
  /logs
  /vendor                       // composer packages
  composer.json
  README.md
  .env.example


## How this works (high-level)

- `public/index.php` is the single entry (front controller). It bootstraps config, loads composer autoload, sets up PDO, session, routing, and middleware stack.
- Controllers handle requests, call Models/Services, then return JSON (API) or render views (templates).
- Models interact with the database via PDO; `BaseModel` centralizes DB access, transactions, and common helpers.
- `services` contain non-HTTP logic: email (PHPMailer), PDF generation (DOMPDF), calendar and reporting helpers.
- `middlewares` enforce authentication, RBAC, CSRF checks, and rate limits.

## Important design choices


- **PDO + prepared statements** for all DB access (prevents SQL injection).
- **RBAC**: user_roles many-to-many; role checks done by `RbacMiddleware` and helper methods.
- **Temp bookings**: `temp_bookings` table holds guest booking until user signs up & verifies; token-based association.
- **Invoices**: generated after appointment creation; PDF generated via `PDFService` and optionally emailed.
- **Payroll**: accountant role has edit rights; admin/manager has view-only access.
- **Session**: server-side sessions; session contains `user_id` and `roles`.