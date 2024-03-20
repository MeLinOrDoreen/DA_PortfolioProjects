SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4;

UPDATE PortfolioProjects..CovidDeaths
SET continent = 'Africa'
WHERE continent = 'Afica';

SELECT *
FROM PortfolioProjects..CovidVaccinations
WHERE continent IS NOT NULL 
ORDER BY 3, 4;

-- Select Data Neccessary

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths *1.0/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE Location LIKE '%state%' AND continent IS NOT NULL 
ORDER BY 1, 2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population get Covid
SELECT Location, date, total_cases, Population, (total_cases *1.0/Population)*100 AS CasePercentage
FROM PortfolioProjects..CovidDeaths
WHERE Location LIKE '%state%' AND continent IS NOT NULL 
ORDER BY 1, 2;

-- Looking at countries with highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases *1.0/Population))*100 AS PercentagePopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE Location LIKE '%state%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC;

-- Looking at countries with Highest Death Count per Population
-- Make data type into integer -> cast(total_deaths as int)
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT


SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Showing Continents with Highest Death Count
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS

-- SELECT date, SUM(new_cases) AS TotalCase, SUM(new_deaths) AS TotalDeath, 
--     SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
-- FROM PortfolioProjects..CovidDeaths
-- WHERE continent IS NOT NULL
-- GROUP BY date 
-- ORDER BY 1, 2;

-- 0 exists in the denominator, it won't work


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
    AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea 
JOIN PortfolioProjects..CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
    AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea 
JOIN PortfolioProjects..CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;



-- TEMP TABLE
DROP TABLE IF exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
    continent NVARCHAR(50),
    location NVARCHAR(50),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
    AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea 
JOIN PortfolioProjects..CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated;


-- Creating View to store data for later visualization
GO
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
    AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea 
JOIN PortfolioProjects..CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;            
GO

SELECT *
FROM PercentagePopulationVaccinated;