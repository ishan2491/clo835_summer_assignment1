CREATE DATABASE IF NOT EXISTS employees;
USE employees;

CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO employees (first_name, last_name, email, department, hire_date) VALUES
("John", "Doe", "john.doe@company.com", "Engineering", "2023-01-15"),
("Jane", "Smith", "jane.smith@company.com", "Marketing", "2023-02-20"),
("Bob", "Johnson", "bob.johnson@company.com", "Sales", "2023-03-10"),
("Alice", "Williams", "alice.williams@company.com", "HR", "2023-04-05"),
("Charlie", "Brown", "charlie.brown@company.com", "Engineering", "2023-05-12");