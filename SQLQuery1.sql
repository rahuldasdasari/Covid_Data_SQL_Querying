---CREATING DATABASE-----
create database covid19_data

use covid19_data

-------NOW LOAD THE GIVEN DATA TO THIS DATABASE FROM TASKS--> IMPORT FLAT FILE OPTION ----------

--------CHECK FOR NULL VALUES-------------

select serious_or_critical, count(*) from Covid_Summary 
where serious_or_critical is null
group by serious_or_critical

---------------INFORMATION_SCHEMA IS TO CHECK DATA INFO (DATA TYPES, NULL VALUES etc)-------
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Covid_Summary';

select * from Covid_Summary

--- REPLACING ALL NULL VALUES FROM EACH COLUMN TO ZERO (0)--------
-----YOU CAN ALSO USE COALESCE() INSTEAD OF ISNULL() FOR BETTER HANDELING-----------
update covid_Summary

set total_recovered = isnull(total_recovered, 0),
active_cases = isnull(active_cases, 0),
 total_deaths_per_1m_population = isnull	(total_deaths_per_1m_population, 0),
total_tests = isnull(total_tests,0),
 total_tests_per_1m_population = isnull(total_tests_per_1m_population, 0);

 update covid_Summary

set total_deaths = isnull(total_deaths, 0);

----------INFORMATION_SCHEMA IS TO CHECK DATA INFO (DATA TYPES, NULL VALUES etc)-------
 select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME ='Covid_Summary'
 select * from Covid_Summary

 --Top 10 countries by confirmed case
 select top 10(country),total_confirmed from covid_Summary
order by total_confirmed desc;

--Find the total confirmed cases, deaths, and recoveries for each continent.

select continent, total_confirmed, total_deaths, total_recovered from Covid_Summary

--Identify the country with the highest number of deaths per 1 million population.

select top 1 country, total_deaths_per_1m_population from Covid_Summary
order by total_deaths_per_1m_population desc;

--Calculate the global death rate (total deaths / total confirmed cases * 100).

select 
sum(total_deaths) [global_deaths],
sum(total_confirmed) [global_confirmed],
((sum(total_deaths)*100)/sum(total_confirmed)) [global_deaths_percentage]
from Covid_Summary


 --Find countries where the number of active cases is greater than 100,000.

 select country, active_cases from Covid_Summary 
 where active_cases > 100000

 --Find total no of contries for each continent
 select count(country)[Total_Countries],continent from Covid_Summary
 group by continent
 order by continent ;

 --Rank top 5 countries based on the number of total tests conducted.

 select top 5 (country), total_tests from Covid_Summary
 order by total_tests desc;

 -- Find the percentage of the population that has been tested in each country.

 select (country), population, 
 (total_tests * 100/population) [Percentage_of_tested_population]
 from Covid_Summary
 order by percentage_of_tested_population desc;

 -- Find the countries with the highest number of serious or critical cases.

 select top 20 (country), (serious_or_critical) [serious_critical] from Covid_Summary
 order by (serious_or_critical) desc;

 --Find the total number of cases and deaths in countries where more than 50% of the population has been tested.

 select country,total_confirmed,total_deaths from Covid_Summary 
 where (total_tests*100/population) > 50 
 order by total_confirmed desc;

 --Calculate the average death rate per continent.

 select continent, avg(total_deaths) [avg_deaths] from Covid_Summary
 group by continent
 order by avg(total_deaths) desc;


 -------------------------------------------------------------------------------------------
 ----------------------------------DATA MANUPULATION AND TRANSFORMATION----------------------------
 select * from Covid_Summary

--Add a New Column to Store Recovery Rate (%)

alter table Covid_Summary
add recovery_rate float;

--To delete a column

ALTER TABLE Covid_Summary
DROP COLUMN store_recovery_rate;

--Populate the recovery_rate column with total_recovered / total_confirmed * 100.

update Covid_Summary
set recovery_rate = (total_recovered/total_confirmed)*100


--Change the column name total_tests to total_tests_conducted.

exec sp_rename 'Covid_Summary.total_tests', 'total_tests_conducted', 'column';

--Create a column risk_level based on active_cases conditions:
--High Risk → More than 1M active cases
--Moderate Risk → Between 100K and 1M active cases
--Low Risk → Below 100K active cases

alter table Covid_Summary
add risk_level varchar (50);

select max(active_cases) from Covid_Summary


UPDATE Covid_Summary
SET risk_level = 
CASE
    WHEN active_cases > 1000000 THEN 'High_Risk'
    WHEN active_cases BETWEEN 100000 AND 1000000 THEN 'Medium_Risk'
    ELSE 'Low_Risk'
END;

--Create a column named fatality_rate to store the death rate per confirmed cases
 select * from Covid_Summary

alter table Covid_Summary 
add fatality_rate float;

-- Populate the fatality_rate column with total_deaths / total_confirmed * 100.

update Covid_Summary
set fatality_rate = (total_deaths/total_confirmed)*100 

--Create a Derived Column in SELECT Statement for Testing Efficiency
--Q: Show a new column "testing_efficiency":
--"High Testing" if more than 50% of the population is tested
--"Moderate Testing" if between 20% and 50%
--"Low Testing" if less than 20%

select country,population,total_tests_conducted,
case
	when ((total_tests_conducted/population)*100) > 50 then 'High Testing'
		when ((total_tests_conducted/population)*100) between 20 and 50 then 'Medium Testing'
		else 'Low Testing'
		end as 'testing_efficiency'
from Covid_Summary
order by total_tests_conducted desc;


--Change the data type of the population column from INT to BIGINT.

ALTER TABLE Covid_Summary
ALTER COLUMN population BIGINT;

select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'Covid_Summary'

--Add a primary key constraint on the country column.

alter table Covid_Summary
add constraint pk_country primary key (country);

-------------------------------------------------------------------------------------
-----------COPY,DELETE,TRANSPOSE-----------------------------------------------------

--Copy entire Rows and Columns
select * into #temp_table from Covid_Summary

select * from #temp_table

--Copy only Structure
select * into #2
from Covid_Summary
where 1 =0;

select * from #2

--to delete permenantly

drop table #2

--to drop only data and keep structure

delete from #temp_table

TRUNCATE TABLE #temp_table

select * from #temp_table

-------------------------------------------THE END-----------------------------



