
SELECT * FROM Covid..['covid deaths$']
SELECT * FROM Covid..['covid vaccinations$']

SELECT location, population, date, total_cases, total_deaths
FROM Covid..['covid deaths$']
ORDER BY 1,3;

--Total cases in different countries
SELECT location, SUM(total_cases) AS total_cases_per_location
FROM ['covid deaths$']
GROUP BY location
ORDER BY location;

--Total cases in india
SELECT location, SUM(total_cases) AS total_cases_india
FROM ['covid deaths$']
WHERE location='India'
GROUP BY location;

--Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM Covid..['covid deaths$']
ORDER BY 1,2;

--What is Percentage of population affected by covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as Affected_percentage
FROM Covid..['covid deaths$']
ORDER BY 1,2;

--Countries with Highest infection rate
SELECT location, population, MAX (total_cases) as Highest_infection_count, MAX(total_cases/population)*100 as Affected_percentage
FROM Covid..['covid deaths$']
GROUP BY location, population
ORDER BY Affected_percentage DESC;

--Countries with highest death count per population
SELECT location, population, MAX(CAST(total_deaths AS int)) AS total_death_count, MAX((CAST(total_deaths as int))/population)*100 AS Death_percentage_per_population
FROM Covid..['covid deaths$']
GROUP BY location, population
ORDER BY Death_percentage_per_population DESC;

--Continents with highest death count per population 
SELECT continent, MAX(CONVERT(int, total_deaths)) AS total_death_count
FROM Covid..['covid deaths$']
WHERE continent is NOT NULL
GROUP BY continent 
ORDER BY total_death_count DESC;


--Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM Covid..['covid deaths$']
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2;

--Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, 
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM Covid..['covid deaths$'] dea
JOIN Covid..['covid vaccinations$'] vac
    ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3;

--Using CTE
With cte1
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM Covid..['covid deaths$'] dea
JOIN Covid..['covid vaccinations$'] vac
    ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM cte1;

--Temp table
 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rolling_people_vaccinated numeric
 )
 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
 FROM Covid..['covid deaths$'] dea
 JOIN Covid..['covid vaccinations$'] vac
    ON dea.location=vac.location
	and dea.date=vac.date
 WHERE dea.continent is NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated;


--creating view for data visualisation
create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM Covid..['covid deaths$'] dea
JOIN Covid..['covid vaccinations$'] vac
    ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is NOT NULL

SELECT * 
FROM PercentPopulationVaccinated;