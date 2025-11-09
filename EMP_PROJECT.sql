CREATE DATABASE ems_project;
USE ems_project;

SHOW DATABASES;
SHOW TABLES;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- ----------------------------
-- 1. Add Primary Keys
-- ----------------------------
ALTER TABLE jobdepartment
ADD PRIMARY KEY (JobID);

ALTER TABLE employee
ADD PRIMARY KEY (EmpID);

ALTER TABLE qualification
ADD PRIMARY KEY (QualID);

ALTER TABLE salary_bonus
ADD PRIMARY KEY (SalaryID);

ALTER TABLE payroll
ADD PRIMARY KEY (PayrollID);

ALTER TABLE leaves
ADD PRIMARY KEY (LeaveID);


-- 1. employee.JobID → jobdepartment.JobID
ALTER TABLE employee
ADD CONSTRAINT fk_employee_job
FOREIGN KEY (JobID) REFERENCES jobdepartment(JobID);

-- 2. leaves.EmpID → employee.EmpID
ALTER TABLE leaves
ADD CONSTRAINT fk_leaves_employee
FOREIGN KEY (EmpID) REFERENCES employee(EmpID);

-- 3. payroll.EmpID → employee.EmpID
ALTER TABLE payroll
ADD CONSTRAINT fk_payroll_employee
FOREIGN KEY (EmpID) REFERENCES employee(EmpID);

-- 4. payroll.JobID → jobdepartment.JobID
ALTER TABLE payroll
ADD CONSTRAINT fk_payroll_job
FOREIGN KEY (JobID) REFERENCES jobdepartment(JobID);

-- 5. payroll.SalaryID → salary_bonus.SalaryID
ALTER TABLE payroll
ADD CONSTRAINT fk_payroll_salary
FOREIGN KEY (SalaryID) REFERENCES salary_bonus(SalaryID);

-- 6. payroll.LeaveID → leaves.LeaveID
ALTER TABLE payroll
ADD CONSTRAINT fk_payroll_leave
FOREIGN KEY (LeaveID) REFERENCES leaves(LeaveID);

-- 7. qualification.EmpID → employee.EmpID
ALTER TABLE qualification
ADD CONSTRAINT fk_qualification_employee
FOREIGN KEY (EmpID) REFERENCES employee(EmpID);

-- 8. salary_bonus.JobID → jobdepartment.JobID
ALTER TABLE salary_bonus
ADD CONSTRAINT fk_salary_job
FOREIGN KEY (JobID) REFERENCES jobdepartment(JobID);





SELECT * FROM JobDepartment;
SELECT * FROM Salary_Bonus;
SELECT * FROM employee;
SELECT * FROM Qualification;
SELECT * FROM Leaves;
SELECT * FROM Payroll;



-- ========================================================
-- 1. EMPLOYEE INSIGHTS
-- ========================================================

-- 1.a How many unique employees are currently in the system?
SELECT COUNT(DISTINCT EmpID) AS TotalEmployees
FROM employee;

-- 1.b Which departments have the highest number of employees?
SELECT j.JobDept, COUNT(e.EmpID) AS NumEmployees
FROM employee e
JOIN jobdepartment j ON e.JobID = j.JobID
GROUP BY j.JobDept
ORDER BY NumEmployees DESC;

-- 1.c What is the average salary per department?
SELECT j.JobDept, AVG(s.Amount) AS AvgSalary
FROM employee e
JOIN jobdepartment j ON e.JobID = j.JobID
JOIN salary_bonus s ON e.JobID = s.JobID
GROUP BY j.JobDept;

-- 1.d Who are the top 5 highest-paid employees?
SELECT e.EmpID, e.FirstName, e.LastName, s.Amount AS Salary
FROM employee e
JOIN salary_bonus s ON e.JobID = s.JobID
ORDER BY s.Amount DESC
LIMIT 5;

-- 1.e What is the total salary expenditure across the company?
SELECT SUM(s.Amount) AS TotalSalaryExpenditure
FROM employee e
JOIN salary_bonus s ON e.JobID = s.JobID;


-- ========================================================
-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- ========================================================

-- 2.a How many different job roles exist in each department?
SELECT JobDept, COUNT(DISTINCT Name) AS NumJobRoles
FROM jobdepartment
GROUP BY JobDept;

-- 2.b What is the average salary range per department?
SELECT j.JobDept, AVG(s.Amount) AS AvgSalary
FROM jobdepartment j
JOIN salary_bonus s ON j.JobID = s.JobID
GROUP BY j.JobDept;

-- 2.c Which job roles offer the highest salary?
SELECT Name AS JobRole, MAX(s.Amount) AS MaxSalary
FROM jobdepartment j
JOIN salary_bonus s ON j.JobID = s.JobID
GROUP BY Name
ORDER BY MaxSalary DESC;

-- 2.d Which departments have the highest total salary allocation?
SELECT j.JobDept, SUM(s.Amount) AS TotalSalary
FROM jobdepartment j
JOIN salary_bonus s ON j.JobID = s.JobID
GROUP BY j.JobDept
ORDER BY TotalSalary DESC;


-- ========================================================
-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- ========================================================

-- 3.a How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT EmpID) AS EmployeesWithQualification
FROM qualification;

-- 3.b Which positions require the most qualifications?
SELECT Position, COUNT(QualID) AS NumQualifications
FROM qualification
GROUP BY Position
ORDER BY NumQualifications DESC;

-- 3.c Which employees have the highest number of qualifications?
SELECT e.EmpID, e.FirstName, e.LastName, COUNT(q.QualID) AS NumQualifications
FROM employee e
JOIN qualification q ON e.EmpID = q.EmpID
GROUP BY e.EmpID, e.FirstName, e.LastName
ORDER BY NumQualifications DESC;


-- ========================================================
-- 4. LEAVE AND ABSENCE PATTERNS
-- ========================================================

-- 4.a Which year had the most employees taking leaves?
SELECT SUBSTRING(Date, 1, 4) AS Year, COUNT(DISTINCT EmpID) AS NumEmployees
FROM leaves
GROUP BY Year
ORDER BY NumEmployees DESC;

-- 4.b Average number of leave days per department
SELECT j.JobDept, AVG(LeaveCount) AS AvgLeaves
FROM (
    SELECT e.EmpID, e.JobID, COUNT(l.LeaveID) AS LeaveCount
    FROM employee e
    LEFT JOIN leaves l ON e.EmpID = l.EmpID
    GROUP BY e.EmpID, e.JobID
) AS emp_leaves
JOIN jobdepartment j ON emp_leaves.JobID = j.JobID
GROUP BY j.JobDept;

-- 4.c Employees who have taken the most leaves
SELECT e.EmpID, e.FirstName, e.LastName, COUNT(l.LeaveID) AS NumLeaves
FROM employee e
JOIN leaves l ON e.EmpID = l.EmpID
GROUP BY e.EmpID, e.FirstName, e.LastName
ORDER BY NumLeaves DESC;

-- 4.d Total number of leave days company-wide
SELECT COUNT(LeaveID) AS TotalLeaves
FROM leaves;

-- 4.e Correlation between leave days and payroll amounts
SELECT e.EmpID, e.FirstName, e.LastName, COUNT(l.LeaveID) AS NumLeaves, SUM(p.TotalAmount) AS TotalPayroll
FROM employee e
LEFT JOIN leaves l ON e.EmpID = l.EmpID
LEFT JOIN payroll p ON e.EmpID = p.EmpID
GROUP BY e.EmpID, e.FirstName, e.LastName;


-- ========================================================
-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- ========================================================

-- 5.a Total monthly payroll processed
SELECT SUBSTRING(Date, 1, 7) AS Month, SUM(TotalAmount) AS TotalPayroll
FROM payroll
GROUP BY Month
ORDER BY Month;

-- 5.b Average bonus given per department
SELECT j.JobDept, AVG(s.Bonus) AS AvgBonus
FROM employee e
JOIN jobdepartment j ON e.JobID = j.JobID
JOIN salary_bonus s ON e.JobID = s.JobID
GROUP BY j.JobDept;

-- 5.c Which department receives the highest total bonuses?
SELECT j.JobDept, SUM(s.Bonus) AS TotalBonus
FROM employee e
JOIN jobdepartment j ON e.JobID = j.JobID
JOIN salary_bonus s ON e.JobID = s.JobID
GROUP BY j.JobDept
ORDER BY TotalBonus DESC;

-- 5.d Average value of total_amount after considering leave deductions
SELECT AVG(TotalAmount) AS AvgTotalAmount
FROM payroll;
