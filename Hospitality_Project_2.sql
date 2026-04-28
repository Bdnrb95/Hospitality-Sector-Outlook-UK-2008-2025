-- Creating the Database for the project

CREATE DATABASE hospitality_analysis;

USE hospitality_analysis;

-- Creating the tables

-- Creating the revenue table

CREATE TABLE revenue (
year INT PRIMARY KEY,
accomodation_revenue_m FLOAT,
food_beverage_revenue_m FLOAT,
hospitality_revenue_m FLOAT
);

-- Creating the brexit vacancies table

CREATE TABLE vacancies (
year INT PRIMARY KEY,
hospitality_vacancies_thousands FLOAT
);

-- Creating the vacancy pressure index table

CREATE TABLE vacancy_index (
year INT PRIMARY KEY,
hospitality_vacancy_index FLOAT
);

-- Creating the consumer spending table

CREATE TABLE consumer_spending (
year INT PRIMARY KEY,
consumer_spending_m FLOAT,
consumer_spending_growth_pct FLOAT
);

-- Creating the earnings table

CREATE TABLE wages (
year INT PRIMARY KEY,
awe_weekly_pay FLOAT,
awe_growth_pct FLOAT
);

-- Creating cost of living table 

CREATE TABLE inflation (
year INT PRIMARY KEY,
cost_of_living_index FLOAT,
cost_of_living_growth_pct FLOAT
);

-- Creating table for interest rates

CREATE TABLE interest_rates (
year INT PRIMARY KEY,
avg_interest_rate FLOAT
);

-- Populating the tables with the CSV's using table data import wizard

-- Quick select to make sure it populated right

SELECT *
FROM consumer_spending;

-- Creating a master dataset table to include all the tables to use later for visualisation, using the revenue as priamry table and using left join on revenue year to relate to all the tables 

CREATE TABLE master_table AS
SELECT
	r.year,
    r.hospitality_revenue_m,
    w.awe_weekly_pay,
    w.awe_growth_pct,
    vi.hospitality_vacancy_index,
    v.hospitality_vacancies_thousands,
    ir.avg_interest_rate,
    i.cost_of_living_index,
    i.cost_of_living_growth_pct,
	c.consumer_spending_m,
    c.consumer_spending_growth_pct
FROM revenue r 
LEFT JOIN wages w ON r.year = w.year
LEFT JOIN vacancy_index vi ON r.year = vi.year
LEFT JOIN vacancies v ON r.year = v.year
LEFT JOIN interest_rates ir ON r.year = ir.year
LEFT JOIN inflation i ON r.year = i.year
LEFT JOIN consumer_spending c ON r.year = c.year
ORDER BY r.year;

-- Creating the final table to use for visualisation in tableau, using the master table and creating a wage pressure index (to see how awe and inflation affects consumers and a labour pressure ratio to see how hard to staff the demands)

SELECT 
    *,
    (awe_growth_pct - cost_of_living_growth_pct) AS real_wage_pressure,
    (hospitality_vacancies_thousands / hospitality_revenue_m) AS labour_pressure_ratio
FROM master_table;

-- EDA for the project

-- Trend overview to observe how key variables change over time 

SELECT 
    year,
    hospitality_revenue_m,
    hospitality_vacancies_thousands,
    consumer_spending_m,
    awe_weekly_pay,
    cost_of_living_index,
    avg_interest_rate
FROM master_table
ORDER BY year;

-- Growth comparison compares wage growth vs inflation to measure real income change

SELECT 
    year,
    awe_growth_pct,
    cost_of_living_growth_pct,
    (awe_growth_pct - cost_of_living_growth_pct) AS real_wage_pressure
FROM master_table;

-- Labour vs revenue pressure that relates labour shortages to business output

SELECT 
    year,
    hospitality_vacancies_thousands,
    hospitality_revenue_m,
    (hospitality_vacancies_thousands / hospitality_revenue_m) AS labour_pressure_ratio
FROM master_table;

-- Demand signal to extract consumer spending growth

SELECT 
    year,
    consumer_spending_growth_pct
FROM master_table;

-- Interest rate shock to calculate year-over-year change in interest rates using a window function

SELECT 
    year,
    avg_interest_rate,
    avg_interest_rate - LAG(avg_interest_rate) OVER (ORDER BY year) AS rate_change
FROM master_table;

-- Sector Stress Explration, created a composite stress indicator to combine : labour pressure, inflation pressure and wage dynamics

SELECT 
    year,
    hospitality_vacancy_index,
    cost_of_living_growth_pct,
    awe_growth_pct,
    (
        hospitality_vacancy_index +
        cost_of_living_growth_pct -
        awe_growth_pct
    ) AS stress_index
FROM master_table;