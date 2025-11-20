CREATE TYPE public.study_period_enum AS ENUM (
    'P1',
    'P2',
    'P3',
    'P4'
);

CREATE FUNCTION public.check_max_course_instances() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    current_period public.study_period_enum;
    instance_count INTEGER;
BEGIN
    SELECT study_period INTO current_period
    FROM Course_Instance
    WHERE instance_id = NEW.instance_id;

    SELECT COUNT(DISTINCT A.instance_id) INTO instance_count
    FROM Allocation A
    JOIN Course_Instance CI ON A.instance_id = CI.instance_id
    WHERE
        A.employee_id = NEW.employee_id
        AND CI.study_period = current_period;

    IF instance_count >= 4 THEN
        RAISE EXCEPTION 'Allocation failed: Employee ID % is already assigned to the maximum of 4 different course instances in period %.',
            NEW.employee_id,
            current_period;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TABLE public.address (
    address_id integer NOT NULL,
    address character varying(500) NOT NULL
);

ALTER TABLE public.address ALTER COLUMN address_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.address_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.allocation (
    allocation_id integer NOT NULL,
    instance_id integer NOT NULL,
    employee_id integer NOT NULL,
    teaching_activity_id integer NOT NULL,
    hours_allocated numeric(5,2) NOT NULL
);

ALTER TABLE public.allocation ALTER COLUMN allocation_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.allocation_allocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.course_instance (
    instance_id integer NOT NULL,
    course_layout_id integer NOT NULL,
    study_year integer NOT NULL,
    study_period public.study_period_enum NOT NULL,
    num_students integer NOT NULL
);

ALTER TABLE public.course_instance ALTER COLUMN instance_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_instance_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.course_layout (
    course_layout_id integer NOT NULL,
    course_code character varying(10) NOT NULL,
    course_name character varying(100) NOT NULL,
    hp numeric(4,1) NOT NULL,
    min_students integer NOT NULL,
    max_students integer NOT NULL,
    CONSTRAINT course_layout_check CHECK ((max_students >= min_students)),
    CONSTRAINT course_layout_min_students_check CHECK ((min_students > 0))
);

ALTER TABLE public.course_layout ALTER COLUMN course_layout_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_layout_course_layout_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.department (
    department_id integer NOT NULL,
    department_name character varying(100) NOT NULL,
    manager_id integer
);

ALTER TABLE public.department ALTER COLUMN department_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.department_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.email (
    email_id integer NOT NULL,
    person_id integer NOT NULL,
    email character varying(1000) NOT NULL
);

ALTER TABLE public.email ALTER COLUMN email_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.email_email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    employment_id character varying(20) NOT NULL,
    dept_id integer,
    job_title_id integer,
    supervisor_id integer
);

CREATE TABLE public.employee_skill (
    employee_id integer NOT NULL,
    skill_id integer NOT NULL
);

CREATE TABLE public.job_title (
    job_title_id integer NOT NULL,
    job_title character varying(50) NOT NULL
);

ALTER TABLE public.job_title ALTER COLUMN job_title_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.job_title_job_title_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.person (
    person_id integer NOT NULL,
    personal_number character varying(13) NOT NULL,
    first_name character varying(500) NOT NULL,
    last_name character varying(500) NOT NULL
);

CREATE TABLE public.person_address (
    person_id integer NOT NULL,
    address_id integer NOT NULL
);

ALTER TABLE public.person ALTER COLUMN person_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.person_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.phone (
    phone_id integer NOT NULL,
    person_id integer NOT NULL,
    phone_number character varying(25) NOT NULL
);

ALTER TABLE public.phone ALTER COLUMN phone_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.phone_phone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.planned_activity (
    course_layout_id integer NOT NULL,
    teaching_activity_id integer NOT NULL,
    planned_hours integer NOT NULL,
    CONSTRAINT planned_activity_planned_hours_check CHECK ((planned_hours >= 0))
);

CREATE TABLE public.salary_history (
    salary_history_id integer NOT NULL,
    employee_id integer NOT NULL,
    salary_amount numeric(10,2) NOT NULL,
    effective_date date NOT NULL
);

ALTER TABLE public.salary_history ALTER COLUMN salary_history_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.salary_history_salary_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.skill (
    skill_id integer NOT NULL,
    skill_name character varying(50) NOT NULL
);

ALTER TABLE public.skill ALTER COLUMN skill_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.skill_skill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.teaching_activity (
    teaching_activity_id integer NOT NULL,
    activity_name character varying(50) NOT NULL,
    factor numeric(5,2) NOT NULL
);

ALTER TABLE public.teaching_activity ALTER COLUMN teaching_activity_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.teaching_activity_teaching_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

COPY public.address (address_id, address) FROM stdin;
\.

COPY public.allocation (allocation_id, instance_id, employee_id, teaching_activity_id, hours_allocated) FROM stdin;
\.

COPY public.course_instance (instance_id, course_layout_id, study_year, study_period, num_students) FROM stdin;
\.

COPY public.course_layout (course_layout_id, course_code, course_name, hp, min_students, max_students) FROM stdin;
\.

COPY public.department (department_id, department_name, manager_id) FROM stdin;
\.

COPY public.email (email_id, person_id, email) FROM stdin;
\.

COPY public.employee (employee_id, employment_id, dept_id, job_title_id, supervisor_id) FROM stdin;
\.

COPY public.employee_skill (employee_id, skill_id) FROM stdin;
\.

COPY public.job_title (job_title_id, job_title) FROM stdin;
\.

COPY public.person (person_id, personal_number, first_name, last_name) FROM stdin;
\.

COPY public.person_address (person_id, address_id) FROM stdin;
\.

COPY public.phone (phone_id, person_id, phone_number) FROM stdin;
\.

COPY public.planned_activity (course_layout_id, teaching_activity_id, planned_hours) FROM stdin;
\.

COPY public.salary_history (salary_history_id, employee_id, salary_amount, effective_date) FROM stdin;
\.

COPY public.skill (skill_id, skill_name) FROM stdin;
\.

COPY public.teaching_activity (teaching_activity_id, activity_name, factor) FROM stdin;
\.

SELECT pg_catalog.setval('public.address_address_id_seq', 1, false);

SELECT pg_catalog.setval('public.allocation_allocation_id_seq', 1, false);

SELECT pg_catalog.setval('public.course_instance_instance_id_seq', 1, false);

SELECT pg_catalog.setval('public.course_layout_course_layout_id_seq', 1, false);

SELECT pg_catalog.setval('public.department_department_id_seq', 1, false);

SELECT pg_catalog.setval('public.email_email_id_seq', 1, false);

SELECT pg_catalog.setval('public.job_title_job_title_id_seq', 1, false);

SELECT pg_catalog.setval('public.person_person_id_seq', 1, false);

SELECT pg_catalog.setval('public.phone_phone_id_seq', 1, false);

SELECT pg_catalog.setval('public.salary_history_salary_history_id_seq', 1, false);

SELECT pg_catalog.setval('public.skill_skill_id_seq', 1, false);

SELECT pg_catalog.setval('public.teaching_activity_teaching_activity_id_seq', 1, false);

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_address_key UNIQUE (address);

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_pkey PRIMARY KEY (allocation_id);

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT course_instance_course_layout_id_study_year_study_period_key UNIQUE (course_layout_id, study_year, study_period);

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT course_instance_pkey PRIMARY KEY (instance_id);

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT course_layout_course_code_key UNIQUE (course_code);

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT course_layout_pkey PRIMARY KEY (course_layout_id);

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_department_name_key UNIQUE (department_name);

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (department_id);

ALTER TABLE ONLY public.email
    ADD CONSTRAINT email_email_key UNIQUE (email);

ALTER TABLE ONLY public.email
    ADD CONSTRAINT email_pkey PRIMARY KEY (email_id);

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_employment_id_key UNIQUE (employment_id);

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);

ALTER TABLE ONLY public.employee_skill
    ADD CONSTRAINT employee_skill_pkey PRIMARY KEY (employee_id, skill_id);

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT job_title_job_title_key UNIQUE (job_title);

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT job_title_pkey PRIMARY KEY (job_title_id);

ALTER TABLE ONLY public.person_address
    ADD CONSTRAINT person_address_pkey PRIMARY KEY (person_id, address_id);

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_personal_number_key UNIQUE (personal_number);

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);

ALTER TABLE ONLY public.phone
    ADD CONSTRAINT phone_person_id_phone_number_key UNIQUE (person_id, phone_number);

ALTER TABLE ONLY public.phone
    ADD CONSTRAINT phone_pkey PRIMARY KEY (phone_id);

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT planned_activity_pkey PRIMARY KEY (course_layout_id, teaching_activity_id);

ALTER TABLE ONLY public.salary_history
    ADD CONSTRAINT salary_history_employee_id_effective_date_key UNIQUE (employee_id, effective_date);

ALTER TABLE ONLY public.salary_history
    ADD CONSTRAINT salary_history_pkey PRIMARY KEY (salary_history_id);

ALTER TABLE ONLY public.skill
    ADD CONSTRAINT skill_pkey PRIMARY KEY (skill_id);

ALTER TABLE ONLY public.skill
    ADD CONSTRAINT skill_skill_name_key UNIQUE (skill_name);

ALTER TABLE ONLY public.teaching_activity
    ADD CONSTRAINT teaching_activity_activity_name_key UNIQUE (activity_name);

ALTER TABLE ONLY public.teaching_activity
    ADD CONSTRAINT teaching_activity_pkey PRIMARY KEY (teaching_activity_id);

CREATE TRIGGER enforce_max_instance_limit BEFORE INSERT ON public.allocation FOR EACH ROW EXECUTE FUNCTION public.check_max_course_instances();

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.course_instance(instance_id);

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_teaching_activity_id_fkey FOREIGN KEY (teaching_activity_id) REFERENCES public.teaching_activity(teaching_activity_id);

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT course_instance_course_layout_id_fkey FOREIGN KEY (course_layout_id) REFERENCES public.course_layout(course_layout_id);

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employee(employee_id);

ALTER TABLE ONLY public.email
    ADD CONSTRAINT email_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id);

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_dept_id_fkey FOREIGN KEY (dept_id) REFERENCES public.department(department_id);

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.person(person_id);

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_job_title_id_fkey FOREIGN KEY (job_title_id) REFERENCES public.job_title(job_title_id);

ALTER TABLE ONLY public.employee_skill
    ADD CONSTRAINT employee_skill_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);

ALTER TABLE ONLY public.employee_skill
    ADD CONSTRAINT employee_skill_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skill(skill_id);

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_supervisor_id_fkey FOREIGN KEY (supervisor_id) REFERENCES public.employee(employee_id);

ALTER TABLE ONLY public.person_address
    ADD CONSTRAINT person_address_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id);

ALTER TABLE ONLY public.person_address
    ADD CONSTRAINT person_address_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id);

ALTER TABLE ONLY public.phone
    ADD CONSTRAINT phone_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id);

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT planned_activity_course_layout_id_fkey FOREIGN KEY (course_layout_id) REFERENCES public.course_layout(course_layout_id);

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT planned_activity_teaching_activity_id_fkey FOREIGN KEY (teaching_activity_id) REFERENCES public.teaching_activity(teaching_activity_id);

ALTER TABLE ONLY public.salary_history
    ADD CONSTRAINT salary_history_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);