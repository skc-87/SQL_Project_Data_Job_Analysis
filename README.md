# 📊 Data Analyst Job Market Analysis — SQL Project

Exploring the data analyst job market to uncover **top-paying roles**, **in-demand skills**, and the **sweet spot where high demand meets high salary**. This project was built to help me (and others) make smarter decisions about which skills to prioritize when navigating the data job market.

🔍 SQL queries used in this project: [project_sql folder](/project_sql/)

---

## Background

I built this project to sharpen my SQL skills while answering real questions I had about the data analyst job market — What roles pay the most? What skills do employers actually want? Where should I focus my learning?

The dataset includes information on job titles, salaries, locations, and required skills pulled from real job postings.

### Questions I set out to answer:

1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?

---

## 🛠 Tools Used

- **SQL** — core of the entire analysis; used to query, join, filter, and aggregate data
- **PostgreSQL** — database management system used to store and query job posting data
- **Visual Studio Code** — used for writing and executing SQL queries
- **Git & GitHub** — version control and project sharing

---

## 📂 The Analysis

### 1. Top-Paying Data Analyst Jobs

Filtered remote data analyst positions by average yearly salary to find the highest-paying opportunities.

```sql
SELECT	
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND 
    job_location = 'Anywhere' AND 
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```

**Key findings:**
- Top 10 remote data analyst roles range from **$184,000 to $650,000** — massive salary potential in this field
- High-paying roles span companies like SmartAsset, Meta, and AT&T, showing demand across many industries
- Job titles vary widely — from Data Analyst to Director of Analytics — reflecting diverse specializations

![Top Paying Roles](assets/1_top_paying_roles.png)
*Bar graph of top 10 salaries for data analysts*

---

### 2. Skills Required for Top-Paying Jobs

Joined job postings with skills data to identify what employers expect from high-salary candidates.

```sql
WITH top_paying_jobs AS (
    SELECT	
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' AND 
        job_location = 'Anywhere' AND 
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```

**Key findings:**
- **SQL** appears in 8 of the top 10 highest-paying job postings
- **Python** follows closely, appearing in 7 postings
- **Tableau** comes in third with 6 mentions
- R, Snowflake, Pandas, and Excel also show up with meaningful frequency

![Top Paying Skills](assets/2_top_paying_roles_skills.png)
*Bar graph of skill counts across top 10 paying data analyst jobs*

---

### 3. Most In-Demand Skills for Data Analysts

Identified the skills most frequently requested across all data analyst job postings.

```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```

| Skills   | Demand Count |
|----------|--------------|
| SQL      | 7,291        |
| Excel    | 4,611        |
| Python   | 4,330        |
| Tableau  | 3,745        |
| Power BI | 2,609        |

*Top 5 most requested skills in remote data analyst job postings*

**Key findings:**
- **SQL** and **Excel** dominate — foundational data skills remain essential
- **Python**, **Tableau**, and **Power BI** reflect the growing importance of programming and data visualization

---

### 4. Skills Associated with Higher Salaries

Explored which skills correlate with the highest average salaries for data analysts.

```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```

| Skills        | Average Salary ($) |
|---------------|-------------------:|
| pyspark       |            208,172 |
| bitbucket     |            189,155 |
| couchbase     |            160,515 |
| watson        |            160,515 |
| datarobot     |            155,486 |
| gitlab        |            154,500 |
| swift         |            153,750 |
| jupyter       |            152,777 |
| pandas        |            151,821 |
| elasticsearch |            145,000 |

*Top 10 highest-paying skills for remote data analysts*

**Key findings:**
- **Big data & ML tools** (PySpark, DataRobot, Jupyter, Pandas) command the highest salaries
- **DevOps/engineering crossover skills** (GitLab, Kubernetes, Airflow) are highly valued — bridging data and engineering pays well
- **Cloud expertise** (Elasticsearch, Databricks, GCP) significantly boosts earning potential

---

### 5. Most Optimal Skills to Learn

Combined demand and salary data to find skills worth prioritizing — high demand *and* high pay.

```sql
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```

| Skills     | Demand Count | Average Salary ($) |
|------------|--------------|-------------------:|
| go         | 27           |            115,320 |
| confluence | 11           |            114,210 |
| hadoop     | 22           |            113,193 |
| snowflake  | 37           |            112,948 |
| azure      | 34           |            111,225 |
| bigquery   | 13           |            109,654 |
| aws        | 32           |            108,317 |
| java       | 17           |            106,906 |
| ssis       | 12           |            106,683 |
| jira       | 20           |            104,918 |

*Most optimal skills ranked by salary (demand threshold: >10 job postings)*

**Key findings:**
- **Python** (236 postings, ~$101K avg) and **R** (148 postings, ~$100K avg) offer great demand and solid salaries — widely valued but also widely available
- **Cloud platforms** like Snowflake, Azure, AWS, and BigQuery show strong demand with high pay — a great investment
- **BI tools** like Tableau and Looker are critical for storytelling and decision support, with competitive salaries around $99K–$104K
- **Database skills** (Oracle, SQL Server, NoSQL) remain in steady demand with salaries ranging from ~$98K–$105K

---

## 💡 What I Learned

Working through this project helped me level up in several ways:

- **Complex Query Crafting** — got comfortable with advanced SQL, including multi-table joins and CTEs (`WITH` clauses) for cleaner, modular queries
- **Data Aggregation** — used `GROUP BY`, `COUNT()`, and `AVG()` extensively to surface meaningful patterns
- **Translating Questions into Queries** — practiced turning business questions into actionable SQL logic, which is a core data analyst skill

---

## ✅ Conclusions

Here's what the analysis revealed:

1. **Top-paying remote data analyst jobs** offer salaries ranging up to **$650,000** — the ceiling is high for the right combination of skills and experience
2. **SQL is non-negotiable** — it appeared in the majority of top-paying job postings and is the most demanded skill overall
3. **Specialized skills pay more** — niche technologies like PySpark, Couchbase, and Solidity command premium salaries
4. **Cloud skills are increasingly important** — Snowflake, Azure, AWS, and BigQuery consistently show up in high-demand, high-salary roles
5. **The most strategic skills to learn** combine strong demand with above-average salaries — SQL, Python, Tableau, and cloud platforms hit this balance well

---

*This project was built as part of my SQL learning journey. All analysis was done independently using PostgreSQL and VS Code.*