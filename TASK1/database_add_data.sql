--- DATA INSERTION ---

INSERT INTO job_title (job_title) VALUES 
('Professor'), 
('Associate Professor'), 
('Lecturer'), 
('PhD Student'); 

INSERT INTO study_period (period_name, start_date, end_date) VALUES 
('P1', '2025-01-13', '2025-03-23'), 
('P2', '2025-03-24', '2025-06-01'), 
('P3', '2025-06-02', '2025-08-10'), 
('P4', '2025-08-11', '2025-10-19'); 

INSERT INTO teaching_activity (activity_name, factor) VALUES 
('Lecture', 3.60), 
('Tutorial', 2.40), 
('Lab', 2.40), 
('Seminar', 1.80),
('Others', 1.00), 
('Exam', NULL), 
('Admin', NULL); 

INSERT INTO skill (skill_name) VALUES
('Database Design'), 
('Python Programming'), 
('Discrete Math'), 
('Algorithms'),
('Frontend Design'),
('Machine Learning');

INSERT INTO department (department_name) VALUES 
('Computer Science'); 

INSERT INTO person (personal_number, first_name, last_name) VALUES 
('197505101234', 'Alice', 'Smith'), 
('198012015678', 'Bob', 'Jones'), 
('199007209012', 'Charlie', 'Brown'),
('199503154321', 'Diana', 'White'), 
('198811228765', 'Eve', 'Green'); 

INSERT INTO phone (person_id, phone_number) VALUES 
(1, '+46701111111'), (2, '+46702222222'), (3, '+46703333333'), (4, '+46704444444'), (5, '+46705555555');

INSERT INTO email (person_id, email) VALUES 
(1, 'alice.smith@university.edu'), (2, 'bob.jones@university.edu'), (3, 'charlie.brown@university.edu'), 
(4, 'diana.white@university.edu'), (5, 'eve.green@university.edu');

INSERT INTO address (person_id, street_address) VALUES 
(1, '123 Elm Street, Apt 4B'), (2, '45 Pine Avenue, House 2'), (3, '67 Oak Drive, Unit 1A'), 
(4, '10 Maple Road, Floor 5'), (5, '11 Birch Lane, Cottage');

INSERT INTO employee (person_id, job_title_id, department_id, supervisor_id) VALUES 
(1, 1, 1, NULL); 

INSERT INTO employee (person_id, job_title_id, department_id, supervisor_id) VALUES 
(2, 2, 1, 1),
(3, 3, 1, 1),
(4, 3, 1, 1),
(5, 4, 1, 2);

UPDATE department SET manager_id = 1 WHERE department_id = 1;

INSERT INTO employee_skill (employment_id, skill_id) VALUES
(2, 1), (2, 2), 
(3, 3), (3, 4), 
(4, 5), 
(5, 6); 

INSERT INTO salary_history(employment_id, effective_date, salary) VALUES
(1, '2025-01-01', 70000.00),
(2, '2025-01-01', 55000.00),
(3, '2025-01-01', 45000.00),
(4, '2025-01-01', 40000.00),
(5, '2025-01-01', 35000.00);


INSERT INTO course_layout (course_code, course_name, hp, min_students, max_students, version) VALUES 
('IV1351', 'Data Storage Paradigms', 7.5, 10, 250, 1),
('IX1500', 'Discrete Mathematics', 7.5, 10, 200, 1),
('IV1010', 'Programming Basics', 7.5, 10, 300, 1), 
('ML2000', 'Machine Learning Intro', 10.0, 20, 150, 1), 
('FE3000', 'Advanced Frontend', 5.0, 15, 100, 1); 


INSERT INTO course_instance (course_layout_id, study_period_id, study_year, num_students) VALUES 
(1, 2, '2025', 200), -- IV1351, P2
(2, 1, '2025', 150), -- IX1500, P1
(3, 1, '2025', 250), -- IV1010, P1
(4, 2, '2025', 120), -- ML2000, P2
(5, 1, '2025', 90), -- FE3000, P1
(3, 2, '2025', 180), -- IV1010, P2 
(2, 3, '2025', 100); -- IX1500, P3


-- IV1351, P2
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES 
(1, 1, 20.0), (1, 2, 80.0), (1, 3, 40.0), (1, 4, 80.0), (1, 5, 65.0); 

-- IX1500, P1
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES 
(2, 1, 44.0), (2, 2, 64.0), (2, 4, 20.0), (2, 5, 14.0); 

-- IV1010, P1
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES 
(3, 1, 60.0), (3, 3, 30.0), (3, 5, 10.0);

-- ML2000, P2
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES 
(4, 1, 40.0), (4, 4, 60.0), (4, 5, 20.0);

-- FE3000, P1
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES 
(5, 2, 45.0), (5, 3, 25.0), (5, 5, 5.0);

-- IV1010, P2
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES 
(6, 1, 30.0), (6, 3, 15.0); 

-- IX1500, P3
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES 
(7, 2, 30.0), (7, 4, 10.0);




-- Bob IV1351 Lecture 20 hours 
INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 2, pa.planned_activity_id, 20.0
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
WHERE ci.course_layout_id = 1 
  AND pa.teaching_activity_id = 1
ON CONFLICT (employment_id, planned_activity_id) DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;


-- Charlie IX1500 Tutorial 64 hours
INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 3, pa.planned_activity_id, 64.0
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
WHERE ci.course_layout_id = 2 
  AND pa.teaching_activity_id = 2
ON CONFLICT (employment_id, planned_activity_id) DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;





INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 1, pa.planned_activity_id, 30.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE cl.course_code = 'IV1351' AND ci.study_year = '2025' AND ta.activity_name = 'Lab'
ON CONFLICT (employment_id, planned_activity_id) 
DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;


INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 1, pa.planned_activity_id, 16.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE cl.course_code = 'IX1500' AND ci.study_year = '2025' AND ta.activity_name = 'Seminar'
ON CONFLICT (employment_id, planned_activity_id) 
DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;


INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 1, pa.planned_activity_id, 15.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE cl.course_code = 'IV1010' 
AND ci.study_year = '2025' 
AND ta.activity_name = 'Lab'
ON CONFLICT (employment_id, planned_activity_id) 
DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;


INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 1, pa.planned_activity_id, 10.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE cl.course_code = 'IX1500' 
AND ci.study_year = '2025' 
AND ta.activity_name = 'Tutorial'
ON CONFLICT (employment_id, planned_activity_id) 
DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;


INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 1, pa.planned_activity_id,5.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE cl.course_code = 'FE3000' 
AND ci.study_year = '2025' 
AND ta.activity_name = 'Tutorial'
ON CONFLICT (employment_id, planned_activity_id) 
DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;

INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 1, pa.planned_activity_id, 15.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE cl.course_code = 'IV1010' AND ci.study_year = '2025' AND ta.activity_name = 'Lecture' AND ci.study_period_id = 2
ON CONFLICT (employment_id, planned_activity_id) 
DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;

INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 4, pa.planned_activity_id, 30.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE ci.study_year = '2025' AND cl.course_code = 'ML2000' AND ta.activity_name = 'Seminar'
ON CONFLICT (employment_id, planned_activity_id) DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;


INSERT INTO allocation (employment_id, planned_activity_id, allocated_hours)
SELECT 5, pa.planned_activity_id, 25.0 
FROM planned_activity pa
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
WHERE ci.study_year = '2025' AND cl.course_code = 'FE3000' AND ta.activity_name = 'Lab'
ON CONFLICT (employment_id, planned_activity_id) DO UPDATE SET allocated_hours = EXCLUDED.allocated_hours;