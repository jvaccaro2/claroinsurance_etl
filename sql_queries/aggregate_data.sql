DROP TABLE IF EXISTS claroinsuranceetl.aggregate_data
;
CREATE TABLE claroinsuranceetl.aggregate_data

WITH CTE_census AS (
SELECT state
	  ,SUM(population) population
      ,SUM(CASE WHEN sex = "Male" THEN population ELSE 0 END) male_pop
      ,SUM(CASE WHEN sex = "Female" THEN population ELSE 0 END) female_pop
      ,SUM(CASE WHEN age IN ("18 and 19 years"
								,"20 years"
                                ,"21 years"
                                ,"22 to 24 years"
                                ,"25 to 29 years"
                                ,"30 to 34 years"
                                ,"35 to 39 years"
                                ,"40 to 44 years"
                                ,"45 to 49 years"
                                ,"50 to 54 years"
                                ,"55 to 59 years"
                                ,"60 and 61 years"
                                ,"62 to 64 years") THEN population ELSE 0 END) pop_18_64yr
FROM claroinsuranceetl.census_data
WHERE sex <> "TOTAL" AND age <> "TOTAL"
GROUP BY state
),
CTE_unins AS (
SELECT state
	  ,SUM(unins_population) unins_population
      ,SUM(CASE WHEN age in ("Age 19-34","Age 35-49","Age 50-64") THEN unins_population ELSE 0 END) unins_19_64yr
FROM claroinsuranceetl.unins_data
GROUP BY state
),
CTE_covid AS (
SELECT state
      ,SUM(confirmed_cases) covid_cases
      ,SUM(deaths) covid_deaths
FROM claroinsuranceetl.covid_data
GROUP BY state
),
CTE_states AS (
SELECT * FROM claroinsuranceetl.states_ids
)
SELECT J2.geo_id state_id
      ,J2.state
      ,J2.state_name
      ,J0.population
      ,J0.male_pop
      ,J0.female_pop
      ,J0.pop_18_64yr
      ,J1.unins_population
      ,J1.unins_19_64yr
      ,J3.covid_cases
      ,J3.covid_deaths
      ,ROUND(J0.male_pop/J0.population,3) ratio_male_pop
      ,ROUND(J0.female_pop/J0.population,3) ratio_female_pop
      ,ROUND(J0.male_pop/J0.female_pop,3) ratio_male_female
      ,ROUND(J1.unins_population/J0.population,3) ratio_unins_pop
      ,ROUND(J1.unins_19_64yr/J0.pop_18_64yr,3) ratio_unins_18_64yr
      ,ROUND(J3.covid_cases/J0.population,3) ratio_covid_pop
      ,ROUND(J3.covid_deaths/J3.covid_cases,3) ratio_covid_deaths
FROM CTE_census AS J0
INNER JOIN CTE_unins AS J1
ON J0.state = J1.state
LEFT JOIN CTE_states AS J2
ON J0.state = J2.state_name
LEFT JOIN CTE_covid AS J3
ON J2.state = J3.state
