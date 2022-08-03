SELECT *
FROM Projects..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM Projects..CovidVaccinations$
--ORDER BY 3,4;

-- Select the data that will be used 

SELECT Location, date, total_cases, new_cases, total_deaths, new_deaths, population 
FROM Projects..CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases versus Total Deaths 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM Projects..CovidDeaths$
WHERE location like '%States%' and continent is not null 
ORDER BY 1,2

-- Looking at total cases versus population 
SELECT  Location, continent, total_cases, Population, (total_cases/population)*100 as percent_population_infected
FROM Projects..CovidDeaths$
WHERE location like '%states%' and 
continent is not null
ORDER BY 1,2

SELECT  Location, date, total_cases, Population, (total_cases/population)*100 as percent_population_infected
FROM Projects..CovidDeaths$
WHERE continent is not null 
ORDER BY 1,2

-- looking at total death versus population 

SELECT location, date, total_deaths, population, (total_deaths/population)*100 AS PercentPopulationCovidDeath
FROM Projects..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--looking at countries with highest infection rate 

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100
AS percent_population_infected
FROM Projects..CovidDeaths$
WHERE continent is not null
GROUP BY population, location
ORDER BY 1,2

-- Showing countries with the highest death count per population 

SELECT Location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM Projects..CovidDeaths$
WHERE continent is not null and total_deaths is not null
GROUP BY Location 
ORDER BY total_death_count desc;

SELECT Location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM Projects..CovidDeaths$
WHERE continent is not null and total_deaths is not null
GROUP BY Location
ORDER BY total_death_count desc;

-- showing the continents with the highest death count per population 

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM Projects..CovidDeaths$
WHERE continent is not null and total_deaths is not null
GROUP BY continent
ORDER BY total_death_count desc;

-- Global Data 

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM Projects..CovidDeaths$
WHERE continent is not null 

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM Projects..CovidDeaths$
WHERE continent is not null 
GROUP BY date 
ORDER BY 1,2

-- Looking at total population versus vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Projects..CovidDeaths$ dea
JOIN Projects..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE

WITH PopVsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Projects..CovidDeaths$ dea
JOIN Projects..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

---Temp Table

SET ANSI_WARNINGS OFF
GO

DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population NUMERIC,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Projects..CovidDeaths$ dea
JOIN Projects..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for visualizations 

CREATE VIEW PercentPopulationVaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Projects..CovidDeaths$ dea
JOIN Projects..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


