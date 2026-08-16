# KTH_IV1351 - Relational Database Project

This repository contains the database design, creation scripts, and queries for a relational database school project (Course: **KTH_IV1351**). The database is built using **PostgreSQL** and models university course administration, tracking course instances, planned teaching activities, and complex calculations for teacher workload allocation.

## Repository Structure

The project is divided into two main parts, separating the initial database design from the data querying tasks:

*   **`TASK1/`**
    *   `model.asta` / `model.asta.lock`: Astah project files containing the database modeling.
    *   `Log_Phys_model.png`: An image of the Logical and Physical Entity-Relationship diagram.
    *   `database_generation.sql`: The DDL script used to define all tables, constraints, and relationships.
    *   `database_add_data.sql`: The DML script used to populate the database with initial mock data.
*   **`TASK2/`**
    *   *Contains updated versions of the modeling and generation files.*
    *   `queries.sql`: A collection of complex SQL queries designed to extract specific administrative insights, such as teacher workload and course budgets.

## Database Schema

The database consists of several interconnected tables designed to normalize the university's data structure. Key tables include:
*   **`course_layout` & `course_instance`**: Defines the base courses (with credits/HP) and specific instances per study year/period.
*   **`employee`, `person`, & `job_title`**: Stores staff information and designations.
*   **`planned_activity` & `teaching_activity`**: Defines what activities (Lectures, Labs, Seminars, etc.) are scheduled for a course.
*   **`allocation`**: Links employees to planned activities with specific allocated hours.
*   **`study_period`**: Defines the academic periods (P1, P2, P3, P4). 

## Getting Started

To set up this project locally, ensure you have **PostgreSQL** installed and running.

1.  **Create a new database** in your PostgreSQL environment.
2.  **Generate the schema:** Run the `database_generation.sql` script to create all tables and relationships.
3.  **Insert mock data:** Run the `database_add_data.sql` script to populate the database with sample courses, teachers, and allocations.
4.  **Run queries:** Execute the queries found in `TASK2/queries.sql` to test the data output.

## Query Documentation (`TASK2`)

The `queries.sql` file contains four primary queries designed to calculate workload and administrative overhead based on specific formulas.

### Query 1: Total Course Instance Hours
Aggregates the total planned hours for all course instances in a specific study year (e.g., '2025'). It calculates the total hours for Lectures, Tutorials, Labs, and Seminars using a specific weighting factor. It also calculates standard overhead for Administration and Exams based on the number of credits (HP) and enrolled students.

### Query 2: Detailed Teacher Workload per Course
Calculates the detailed workload for individual teachers on a specific course instance (e.g., 'IX1500', Period 1). This query breaks down the hours a teacher spends on various teaching activities and calculates their proportional share of the course's total Administration and Exam overhead based on the fraction of total teaching hours they are allocated to.

### Query 3: Teacher's Overall Annual Workload
Summarizes the total teaching hours and calculated overhead (Admin/Exam) for a specific teacher (e.g., 'Alice Smith') across all the courses they are allocated to during a given study year. 

### Query 4: Teacher Course Load Limit check
Identifies employees who are assigned to more than a specified number of unique course instances (e.g., > 2) during a single study period (e.g., 'P1'). This is useful for identifying scheduling conflicts or over-allocated staff.
