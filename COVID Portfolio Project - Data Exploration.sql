/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM `project-monica-9918.Covid19.Deaths`
WHERE continent is not null
ORDER BY population, total_cases

-- Select Data that we are going to be starting with

SELECT 
  country, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
FROM `project-monica-9918.Covid19.Deaths`
WHERE continent is not null
ORDER BY country, date

-- Total Cases vs Total Deaths
-- The likehood of dying if you contract Covid in your country

SELECT 
  country, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths/total_cases)*100 as DeathPercentage
FROM `project-monica-9918.Covid19.Deaths`
WHERE country like '%Romania%'
AND continent is not null
AND total_cases > 0
ORDER BY country, date

-- Total Cases vs Population
-- Shows what percentage of population got infected with Covid

SELECT 
  country, 
  date, 
  population, 
  total_cases, 
  (total_cases/population)*100 as PercentPopulationInfected
FROM `project-monica-9918.Covid19.Deaths`
--WHERE country like '%Romania%'
ORDER BY country, date

-- Counries with Highest Infection Rate compared to Population

SELECT 
  country, 
  population, 
  MAX(total_cases) as HighestInfectionCount, 
  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `project-monica-9918.Covid19.Deaths`
GROUP BY country, population
ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

SELECT 
  country, 
  MAX(cast(total_deaths as INT64)) as TotalDeathCount
FROM `project-monica-9918.Covid19.Deaths`
WHERE continent is not null
GROUP BY country
ORDER BY TotalDeathCount desc

-- Continents with Highest Death Count per Population

SELECT 
  continent, 
  MAX(cast(total_deaths as INT64)) as TotalDeathCount
FROM `project-monica-9918.Covid19.Deaths`
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global numbers

SELECT 
  SUM(new_cases) as total_cases, 
  SUM(new_deaths) as total_deaths, 
  SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `project-monica-9918.Covid19.Deaths`
WHERE continent is not null


-- Total Population vs Vaccinations
-- Shows the Percentage4 of Population that has received at least one Covid Vaccine

SELECT 
  dea.continent, 
  dea.country,
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `project-monica-9918.Covid19.Deaths` AS dea
JOIN `project-monica-9918.Covid19.Vaccinations` AS vac
  ON dea.country = vac.country
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.country, dea.date

-- Using CTE to perfrom Calculation on Partition By in previous query

WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.country,
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS INT64)) 
        OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) 
        AS RollingPeopleVaccinated
 -- ,(RollingPeopleVaccinated/population)*100
  FROM `project-monica-9918.Covid19.Deaths` AS dea
  JOIN `project-monica-9918.Covid19.Vaccinations` AS vac
    ON dea.country = vac.country
    AND dea.date = vac.date
  WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPopulationPercentage
FROM PopvsVac;


-- Creating View to store data for later visualizations

CREATE VIEW `project-monica-9918.Covid19.PercentPopulationVaccinated` AS
SELECT 
    dea.continent, 
    dea.country,
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS INT64)) 
        OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) 
        AS RollingPeopleVaccinated,
FROM `project-monica-9918.Covid19.Deaths` AS dea
JOIN `project-monica-9918.Covid19.Vaccinations` AS vac
  ON dea.country = vac.country
  AND dea.date = vac.date
WHERE dea.continent is not null
