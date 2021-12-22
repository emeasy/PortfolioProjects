CREATE DATABASE PortfolioProject;
USE portfolioproject;

SELECT * FROM covidvaccinations;
SELECT * FROM coviddeaths
ORDER BY 3,4;

-- SELECT location, date, total_cases, new_cases, total_deaths, population
-- FROM coviddeaths
-- order by 1,2;
SELECT  STR_TO_DATE(date, '%m/%d/%Y') AS date FROM coviddeaths order by date asc;

SELECT location, (STR_TO_DATE(date, '%m/%d/%Y')) as date,
total_cases, total_deaths, (total_deaths/total_cases) * 100 AS 'deathpercentage (%)'
FROM coviddeaths
order by 1,2;


-- lloking at total cases / total deaths
-- Show the likelyhood of dying if you contract covid in your country
SELECT location, (STR_TO_DATE(date, '%m/%d/%Y')) as date,
total_cases, total_deaths, (total_deaths/total_cases) * 100 AS 'deathpercentage (%)'
FROM coviddeaths
WHERE location like '%states%'
order by 1,2;

-- looking at total cases vs population
-- shows what percentage of the population has got covid
SELECT location, (STR_TO_DATE(date, '%m/%d/%Y')) as date, population,
total_cases, (total_cases/population) * 100 AS 'infection_percentage (%)'
FROM coviddeaths
WHERE location like '%nigeria%'
order by 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS 'highest_infection_count', MAX((total_cases/population)) * 100 AS 'population_infection_percentage (%)'
FROM coviddeaths
-- WHERE location like '%nigeria%'
Group by location, population
order by MAX((total_cases/population)) * 100 DESC;


-- Looking at countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
-- WHERE location like '%nigeria%'
WHERE continent != ''
Group by location
order by TotalDeathCount DESC;

-- Looking at continents with the highest death count per population 
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
-- WHERE location like '%nigeria%'
WHERE continent = ''
Group by location
order by TotalDeathCount DESC;

-- Global numbers

SELECT--  (STR_TO_DATE(date, '%m/%d/%Y')) as date,
SUM(new_cases) AS new_cases, SUM(new_deaths) AS total_deaths, 
(SUM(new_deaths)/SUM(new_cases)) * 100 AS 'total_deaths (%)'
FROM coviddeaths
-- WHERE location like '%states%'
WHERE continent != ''
-- group by date
order by 1,2;


-- Using CTE
With PopsVac(Continent, Location, Date, Population, NEw_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, (STR_TO_DATE(dea.date, '%m/%d/%Y')) as date, 
dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
OVER (PARTITION BY dea.location 
ORDER BY dea.location, (STR_TO_DATE(dea.date, '%m/%d/%Y'))) AS RollingPeopleVaccinated
FROM
coviddeaths as dea
INNER JOIN covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
-- order by 2,3 ASC
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 FROM PopsVac;

-- TEMP Table
DROP TABLE PercentPopulaionVaccinated;
CREATE TABLE PercentPopulaionVaccinated(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
);

INSERT INTO PercentPopulaionVaccinated
SELECT dea.continent, dea.location, (STR_TO_DATE(dea.date, '%m/%d/%Y')) as date, 
dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
OVER (PARTITION BY dea.location 
ORDER BY dea.location, (STR_TO_DATE(dea.date, '%m/%d/%Y'))) AS RollingPeopleVaccinated
FROM
coviddeaths as dea
INNER JOIN covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != '';


SELECT *, (RollingPeopleVaccinated/Population) * 100 FROM PercentPopulaionVaccinated;

-- Creating view to store data for lter visualizations

CREATE VIEW PercentPopulaionVaccinatedView as
SELECT dea.continent, dea.location, (STR_TO_DATE(dea.date, '%m/%d/%Y')) as date, 
dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
OVER (PARTITION BY dea.location 
ORDER BY dea.location, (STR_TO_DATE(dea.date, '%m/%d/%Y'))) AS RollingPeopleVaccinated
FROM
coviddeaths as dea
INNER JOIN covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != '';

SELECT * FROM PercentPopulaionVaccinatedView;