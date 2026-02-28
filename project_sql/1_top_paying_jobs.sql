SELECT
        job_id,
        job_title,
        salary_year_avg
FROM
        job_postings_fact
WHERE
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
ORDER BY
        salary_year_avg DESC
LIMIT 10