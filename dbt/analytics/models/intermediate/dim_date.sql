{{ config (schema = 'CORE',
           materialized = 'table') }}

WITH date_spine AS (
    SELECT DATEADD(day, SEQ4(), '2025-01-01':: DATE) AS date_day
    FROM TABLE (GENERATOR(ROWCOUNT => 10000))
) 

SELECT 
  date_day AS date_key,
  date_day,
  YEAR(date_day) AS year,
  QUARTER(date_day) AS quarter,
  MONTH(date_day) AS month,
  MONTHNAME(date_day) AS month_name,
  WEEK(date_day) AS week_of_year,
  DAY(date_day) AS day_of_month,
  DAYOFWEEK(date_day) AS day_of_week,
  DAYNAME(date_day) AS day_name,
  CASE WHEN DAYOFWEEK(date_day) IN (0,7)
       THEN TRUE ELSE FALSE
  END AS is_weekend

FROM date_spine