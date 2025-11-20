INSERT INTO department (department_name) VALUES
('Computer Science'),
('Electrical Engineering'),
('Human Resources');

INSERT INTO job_title (job_title) VALUES
('Professor'),
('Associate Professor'),
('Senior HR Specialist'),
('Department Manager');

INSERT INTO skill (skill_name) VALUES
('SQL Development'),
('Python Programming'),
('Digital Signal Processing'),
('Recruitment');

INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 1.0),
('Lab Session', 1.5),
('Exam Supervision', 2.0);

INSERT INTO course_layout (course_code, course_name, hp, min_students, max_students) VALUES
('DD4001', 'Database Design', 7.5, 30, 50),
('AA5002', 'Advanced Algorithms', 6.0, 15, 35),
('DC3005', 'Digital Circuits', 7.5, 20, 45);

INSERT INTO person (personal_number, first_name, last_name) VALUES
('19800101-1234', 'Jane', 'Doe'),
('19750505-5678', 'John', 'Smith');

INSERT INTO employee (employee_id, employment_id, dept_id, job_title_id) VALUES
(1, 'EMP-JDOE', 1, 1),
(2, 'EMP-JSMT', 1, 4);

UPDATE department SET manager_id = 2 WHERE department_id = 1;

UPDATE employee SET supervisor_id = 2 WHERE employee_id = 1;

INSERT INTO address (address) VALUES
('10 Main Street, Capital City 10123'),
('20 Elm Street, Metro Town 20456');

INSERT INTO person_address (person_id, address_id) VALUES
(1, 1),
(2, 2);

INSERT INTO phone (person_id, phone_number) VALUES
(1, '555-1234'),
(2, '555-5678');

INSERT INTO email (person_id, email) VALUES
(1, 'jane.doe@university.edu'),
(2, 'john.smith@university.edu');

INSERT INTO course_instance (course_layout_id, study_year, study_period, num_students) VALUES
(1, 2024, 'P1'::study_period_enum, 48),
(2, 2025, 'P3'::study_period_enum, 29),
(1, 2024, 'P2'::study_period_enum, 50);

INSERT INTO allocation (instance_id, employee_id, teaching_activity_id, hours_allocated) VALUES
(1, 1, 1, 30.0),
(1, 1, 2, 30.0),
(2, 1, 1, 45.0);

INSERT INTO salary_history (employee_id, salary_amount, effective_date) VALUES
(1, 85000.00, '2023-08-01'),
(2, 105000.00, '2022-01-15'),
(1, 90000.00, '2024-08-01');

INSERT INTO employee_skill (employee_id, skill_id) VALUES
(1, 1),
(1, 2),
(2, 4);

INSERT INTO planned_activity (course_layout_id, teaching_activity_id, planned_hours) VALUES
(1, 1, 30),
(1, 2, 15),
(2, 1, 25);