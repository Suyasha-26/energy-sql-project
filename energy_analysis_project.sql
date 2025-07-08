create database Energydb;

use Energydb;

-- 1. Country Table
create table country_3 (
country varchar(100) primary key,
cid varchar(10) unique
);

-- 2. Emission Table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(100),
    year INT,
    emission FLOAT NULL,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country)  REFERENCES country_3(country)
);

-- 3. Population Table
create table population_3(
countries varchar(255),
`year` int,
`value` double,
foreign key (countries) references country_3(country));

-- 4. Production Table
create table production_3(
country varchar(100),
energy varchar(50),
`year` int,
production int,
foreign key (country) references country_3(country));

-- 5. gdp Table
create table gdp_3(
country varchar(100),
`year` int,
`value` double,
foreign key (country) references country_3(country));

-- 6. Consumption Table
create table consumption_3(
country varchar(100),
energy varchar(50),
`year` int,
consumption int,
foreign key (country) references country_3(country));

## Questions
-- 1. what is the total emmission per country for the most recent year available?
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (
SELECT MAX(year) FROM emission_3)
GROUP BY country;

-- 2. What are the top 5 countries by GDP in the most recent year?
select country,`value`,`year` from gdp_3
where `year` = (select max(`year`) from gdp_3)
order by `year`,`value` desc limit 5 ;

-- 3. Compare energy production and consumption by country and year. 
select a.country,a.energy,a.`year`,b.consumption,a.production from production_3 a 
join consumption_3 b on a.country=b.country
and a.`year` = b.`year`
and a.energy = b.energy
order by production desc;

-- 4. Which energy types contribute most to emissions across all countries?
	select energy_type,sum(per_capita_emission) as total from emission_3 
	group by energy_type
	having total = (
	select max(total)
	from( select energy_type,sum(per_capita_emission) as total from emission_3
	group by energy_type) as sub);


-- 5. How have global emissions changed year over year?
select `year`,sum(emission) as emission_change
from emission_3
group by `year`
order by `year` desc;

-- 6. What is the trend in GDP for each country over the given years?
select country, `year`, `value`  
from gdp_3
order by `value` desc,`year`;

-- 7. How has population growth affected total emissions in each country?
select p.countries,p.`year`,p.`value`,sum(emission) as population_count 
from emission_3 e join population_3 p on e.country = p.countries
and p.`year` = e.`year`
group by p.countries,p.`year`, p.`value`
order by countries,`year`;

-- 8. Has energy consumption increased or decreased over the years for major economies?
SELECT major_economies.country,c.year, SUM(c.consumption) AS total_consumption
FROM consumption_3 c
JOIN
(SELECT country, SUM(value) AS total_gdp
FROM  gdp_3
GROUP BY country
ORDER BY total_gdp DESC LIMIT 5) AS major_economies
ON c.country = major_economies.country
GROUP BY c.year,major_economies.country
ORDER BY c.year desc,major_economies.country;
 
 -- 9. What is the average yearly change in emissions per capita for each country?
select country	, `year` ,round(avg(per_capita_emission),6)
 from emission_3 
group by country,`year`;


-- 10. What is the emission-to-GDP ratio for each country by year?
select e.country, e.year, round(sum(e.emission) / g.`value`,5) as emssion_to_gdp 
from emission_3 e join gdp_3 g on e.country = g.country
and e.`year` = g.`year`
group by country, `year`,g.`value`
order by country,`year`;

-- 11. How does energy production per capita vary across countries?
select a.country,sum(a.production) / sum(b.`value`) as production_per_capita 
from production_3 a join population_3 b on a.country = b.countries
and a.`year` = b.`year`
group by b.countries
order by production_per_capita desc;

-- 12. Which countries have the highest energy consumption relative to GDP?
select c.country , round(sum(c.consumption)/sum(g.`value`),5) as consumption_relative_to_GDP
 from consumption_3 c join gdp_3 g on c.country = g.country
 and c.`year` = g.`year`
 and c.country = g.country
 group by country
 order by consumption_relative_to_GDP desc;
 
-- 13. What are the top 10 countries by population and how do their emissions compare?
select p.countries, sum(p.value)as population,round(sum(e.emission),4) as emission 
from population_3 p join emission_3 e on p.countries = e.country
and e.`year` = p.`year`
group by p.countries
order by population desc limit 10;
 
-- 14. What is the global share (%) of emissions by country?
with cte_1 as (select country, sum(emission) as total_emission from emission_3 
group by country)
select country,round(total_emission*100/(select sum(emission) 
from emission_3),5) as `share`
from cte_1
order by `share` desc;

-- 15. What is the global average GDP, emission, and population by year?
select e.year ,round(avg(g.`value`),4) as gdp_avg, round(avg(e.emission),4) as emission_avg, 
round(sum(p.`value`),5) as population_avg from gdp_3 g 
join emission_3 e on g.country = e.country
and e.`year` = g.`year`
join population_3 p on g.country = p.countries
and g.`year`= p.`year`
group by e.`year`
order by e.`year`;

 -- 16.What is the energy consumption per capita for each country over the last decade?
with recent_years AS (
 SELECT max(`year`) AS max_year FROM consumption_3),
 consumption_data AS (
 SELECT c.country, c.`year`,c.consumption, p.`value` AS population
 FROM consumption_3 c
 JOIN population_3 p
 ON c.country = p.countries AND c.year = p.year
 WHERE c.`year` >= (SELECT max_year - 9 FROM recent_years)
 )SELECT country,`year`,
 ROUND(sum(consumption)/sum(population), 4) AS consumption_per_capita
 FROM consumption_data
 GROUP BY country,`year` 	
 ORDER BY consumption_per_capita desc;
 