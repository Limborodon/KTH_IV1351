-- Query 1
SELECT
    cl.course_code AS "Course Code",
    ci.course_instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    sp.period_name AS "Period",
    ci.num_students AS "# Students",
    

    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor END), 0.00) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor END), 0.00) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN pa.planned_hours * ta.factor END), 0.00) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor END), 0.00) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Others' THEN pa.planned_hours * ta.factor END), 0.00) AS "Other Overhead Hours",
    
    (2 * cl.hp + 28 + 0.2 * ci.num_students) AS "Admin", 
    (32 + 0.725 * ci.num_students) AS "Exam", 
    
    (
        COALESCE(SUM(pa.planned_hours * ta.factor), 0.00) + 
        (2 * cl.hp + 28 + 0.2 * ci.num_students) +
        (32 + 0.725 * ci.num_students)
    ) AS "Total Hours"

FROM course_instance ci
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN study_period sp ON ci.study_period_id = sp.study_period_id
LEFT JOIN planned_activity pa ON ci.course_instance_id = pa.course_instance_id
LEFT JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id

WHERE ci.study_year = '2025'

GROUP BY 
    ci.course_instance_id, 
    cl.course_code, 
    cl.hp, 
    sp.period_name, 
    ci.num_students
ORDER BY cl.course_code, sp.period_name;

-- Query 2

SELECT 
    cl.course_code AS "Course Code",
    ci.course_instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    CONCAT(p.first_name, ' ', p.last_name) AS "Teacher's Name",
    jt.job_title AS "Designation",

    ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN a.allocated_hours * ta.factor ELSE 0 END), 2) AS "Lecture Workload",
    ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN a.allocated_hours * ta.factor ELSE 0 END), 2) AS "Tutorial Workload",  
    ROUND(SUM(CASE WHEN ta.activity_name = 'Lab' THEN a.allocated_hours * ta.factor ELSE 0 END), 2) AS "Lab Workload",
    ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN a.allocated_hours * ta.factor ELSE 0 END), 2) AS "Seminar Workload",

    ROUND(SUM(CASE WHEN ta.activity_name = 'Others' THEN a.allocated_hours * ta.factor ELSE 0 END), 2) AS "Other Workload",
    
    ROUND((2 * cl.hp + 28 + 0.2 * ci.num_students) * (SUM(a.allocated_hours) / NULLIF(
        (SELECT SUM(pa2.planned_hours) 
             FROM planned_activity pa2 
             WHERE pa2.course_instance_id = ci.course_instance_id 
             AND pa2.teaching_activity_id IN (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name NOT IN ('Exam', 'Admin'))
             ), 0)
        ), 2
    ) AS "Admin",

    ROUND(
        (32 + 0.725 * ci.num_students) * (SUM(a.allocated_hours) / NULLIF(
            (SELECT SUM(pa2.planned_hours) 
             FROM planned_activity pa2 
             WHERE pa2.course_instance_id = ci.course_instance_id 
             AND pa2.teaching_activity_id IN (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name NOT IN ('Exam', 'Admin'))
             ), 0)
        ), 2
    ) AS "Exam",
    
    ROUND(
        COALESCE(SUM(a.allocated_hours * COALESCE(ta.factor, 1.0)), 0) +
        -- Admin Share
        (2 * cl.hp + 28 + 0.2 * ci.num_students) * (SUM(a.allocated_hours) / NULLIF(
            (SELECT SUM(pa2.planned_hours) 
             FROM planned_activity pa2 
             WHERE pa2.course_instance_id = ci.course_instance_id 
             AND pa2.teaching_activity_id IN (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name NOT IN ('Exam', 'Admin'))
             ), 0)
        ) +
        -- Exam Share
        (32 + 0.725 * ci.num_students) * (SUM(a.allocated_hours) / NULLIF(
            (SELECT SUM(pa2.planned_hours) 
             FROM planned_activity pa2 
             WHERE pa2.course_instance_id = ci.course_instance_id 
             AND pa2.teaching_activity_id IN (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name NOT IN ('Exam', 'Admin'))
             ), 0)
        ), 2
    ) AS "Total Workload"

FROM course_instance ci
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
JOIN allocation a ON a.planned_activity_id = pa.planned_activity_id
JOIN employee e ON a.employment_id = e.employment_id
JOIN person p ON e.person_id = p.person_id
JOIN job_title jt ON e.job_title_id = jt.job_title_id

WHERE ci.study_year = '2025'
  AND ta.activity_name NOT IN ('Exam', 'Admin')
  AND cl.course_code = 'IX1500'-- change for course to select
  AND ci.study_period_id = 1 -- change for period 
  -- period + course = specific course instance

GROUP BY 
    cl.course_code,
    ci.course_instance_id,
    cl.hp,
    ci.num_students,
    p.first_name,
    p.last_name,
    jt.job_title,
    e.employment_id

ORDER BY 
    cl.course_code,
    ci.course_instance_id,
    "Teacher's Name";
-- Query 3
SELECT
    cl.course_code AS "Course Code",
    ci.course_instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    sp.period_name AS "Period", 
    p.first_name || ' ' || p.last_name AS "Teacher's Name", 

    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN al.allocated_hours * ta.factor END), 0.00) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN al.allocated_hours * ta.factor END), 0.00) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN al.allocated_hours * ta.factor END), 0.00) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN al.allocated_hours * ta.factor END), 0.00) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Others' THEN al.allocated_hours * ta.factor END), 0.00) AS "Other Overhead Hours",

    (2 * cl.hp + 28 + 0.2 * ci.num_students) AS "Admin", 
    (32 + 0.725 * ci.num_students) AS "Exam", 

    (
        COALESCE(SUM(al.allocated_hours * ta.factor), 0.00) +
        (2 * cl.hp + 28 + 0.2 * ci.num_students) +
        (32 + 0.725 * ci.num_students)
    ) AS "Total"
    
FROM allocation al
JOIN employee e ON al.employment_id = e.employment_id
JOIN person p ON e.person_id = p.person_id
JOIN planned_activity pa ON al.planned_activity_id = pa.planned_activity_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN study_period sp ON ci.study_period_id = sp.study_period_id

WHERE ci.study_year = '2025'
-- Enter teacher's name to filter
  AND p.first_name = 'Alice' 
  AND p.last_name = 'Smith'

GROUP BY
    cl.course_code,
    ci.course_instance_id,
    cl.hp,
    sp.period_name,
    p.first_name, 
    p.last_name, 
    ci.num_students 
    
ORDER BY p.last_name, ci.study_period_id, cl.course_code;
-- Query 4
SELECT
    e.employment_id AS "Employment ID",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",
    sp.period_name AS "Period",
    COUNT(DISTINCT ci.course_instance_id) AS "No of courses"
    
FROM allocation al
JOIN employee e ON al.employment_id = e.employment_id
JOIN person p ON e.person_id = p.person_id
JOIN planned_activity pa ON al.planned_activity_id = pa.planned_activity_id
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN study_period sp ON ci.study_period_id = sp.study_period_id

WHERE sp.period_name = 'P1' -- current period
    AND ci.study_year = '2025' -- current year

GROUP BY
    e.employment_id,
    p.first_name,
    p.last_name,
    sp.period_name
    
HAVING 
    COUNT(DISTINCT ci.course_instance_id) > 2 -- change for limit

ORDER BY 
    "No of courses" DESC, 
    "Teacher's Name";