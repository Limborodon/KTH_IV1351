
CREATE TYPE period_name_enum AS ENUM ('P1', 'P2', 'P3', 'P4');

CREATE TABLE job_title (
    job_title_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_title VARCHAR(500) UNIQUE NOT NULL
);

CREATE TABLE person (
    person_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    personal_number VARCHAR(13) UNIQUE NOT NULL,
    first_name VARCHAR(500) NOT NULL,
    last_name VARCHAR(500) NOT NULL
);

CREATE TABLE phone (
    person_id INT NOT NULL REFERENCES person(person_id),
    phone_number VARCHAR(50) NOT NULL,
    PRIMARY KEY (person_id, phone_number)
);

CREATE TABLE address (
    person_id INT NOT NULL REFERENCES person(person_id),
    street_address VARCHAR(500) NOT NULL,
    PRIMARY KEY (person_id, street_address)
);
    
CREATE TABLE email (
    person_id INT NOT NULL REFERENCES person(person_id),
    email VARCHAR(1000) UNIQUE NOT NULL,
    PRIMARY KEY (person_id, email)
);

CREATE TABLE study_period (
    study_period_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    period_name period_name_enum UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE system_settings (
    setting_name VARCHAR(500) PRIMARY KEY,
    setting_value INT NOT NULL
);
INSERT INTO system_settings (setting_name, setting_value) VALUES ('MAX_COURSE_ALLOCATIONS_PER_PERIOD', 4); -- Value cast to INT

CREATE TABLE teaching_activity (
    teaching_activity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    activity_name VARCHAR(500) UNIQUE NOT NULL,
    factor DECIMAL(5, 2)
);

CREATE TABLE skill (
    skill_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    skill_name VARCHAR(200) UNIQUE NOT NULL
);


CREATE TABLE department (
    department_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(500) UNIQUE NOT NULL,
    manager_id INT UNIQUE 
);


CREATE TABLE employee (
    employment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    person_id INT UNIQUE NOT NULL REFERENCES person(person_id),
    job_title_id INT NOT NULL REFERENCES job_title(job_title_id),
    supervisor_id INT REFERENCES employee(employment_id),
    department_id INT NOT NULL REFERENCES department(department_id)
);


ALTER TABLE department ADD CONSTRAINT fk_department_manager
    FOREIGN KEY (manager_id) REFERENCES employee(employment_id);


CREATE TABLE employee_skill(
    employment_id INT NOT NULL REFERENCES employee(employment_id),
    skill_id INT NOT NULL REFERENCES skill(skill_id),
    PRIMARY KEY (employment_id, skill_id)
);


CREATE TABLE salary_history(
    employment_id INT NOT NULL REFERENCES employee(employment_id),
    effective_date DATE NOT NULL,
    salary DECIMAL(20, 2) NOT NULL,
    PRIMARY KEY (employment_id, effective_date)
);


CREATE TABLE course_layout (
    course_layout_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code VARCHAR(100) NOT NULL,
    course_name VARCHAR(500) NOT NULL,
    min_students INT NOT NULL,
    max_students INT NOT NULL,
    hp DECIMAL(5, 2) NOT NULL,
    version INT NOT NULL,
    UNIQUE (course_code, version)
);


CREATE TABLE course_instance (
    course_instance_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    num_students INT NOT NULL,
    study_year VARCHAR(50) NOT NULL,
    course_layout_id INT NOT NULL REFERENCES course_layout(course_layout_id),
    study_period_id INT NOT NULL REFERENCES study_period(study_period_id),
    UNIQUE (course_layout_id, study_year, study_period_id)
);


CREATE TABLE planned_activity (
    planned_activity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    planned_hours DECIMAL(10, 2) NOT NULL,
    teaching_activity_id INT NOT NULL REFERENCES teaching_activity(teaching_activity_id),
    course_instance_id INT NOT NULL REFERENCES course_instance(course_instance_id),
    UNIQUE (course_instance_id, teaching_activity_id)
);


CREATE TABLE allocation (
    employment_id INT NOT NULL REFERENCES employee(employment_id),
    planned_activity_id INT NOT NULL REFERENCES planned_activity(planned_activity_id),
    allocated_hours DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (employment_id, planned_activity_id)
);


CREATE OR REPLACE FUNCTION check_max_course_allocation()
RETURNS TRIGGER AS $$
DECLARE
    current_period_id INT;
    max_limit INT;
    course_count INT;
BEGIN
    
    SELECT ci.study_period_id INTO current_period_id
    FROM planned_activity pa
    JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
    WHERE pa.planned_activity_id = NEW.planned_activity_id;
    

    SELECT setting_value INTO max_limit
    FROM system_settings
    WHERE setting_name = 'MAX_COURSE_ALLOCATIONS_PER_PERIOD';
    

    SELECT COUNT(DISTINCT ci.course_instance_id) INTO course_count
    FROM allocation a
    JOIN planned_activity pa ON a.planned_activity_id = pa.planned_activity_id
    JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
    WHERE a.employment_id = NEW.employment_id
      AND ci.study_period_id = current_period_id;
    

    IF course_count >= max_limit THEN
        RAISE EXCEPTION 'Employee % already allocated to % courses in period %.',
            NEW.employment_id, course_count, current_period_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_max_course_allocation
BEFORE INSERT ON allocation
FOR EACH ROW
EXECUTE FUNCTION check_max_course_allocation();
<