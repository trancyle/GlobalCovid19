SELECT * FROM .CovidDeaths 

ORDER BY 3,4 

SELECT * FROM .CovidVaccination
WHERE Continent is not NULL
ORDER BY 3,4

--Select data that is needed
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE Continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths in New Zealand
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%zealand%' AND Continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs. Total Population in New Zealand
SELECT location, date, total_cases, population, (total_deaths/population)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%zealand%' AND Continent is not NULL
ORDER BY 1,2

--Looking at country with highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionNumber, MAX((total_deaths/population)*100) AS PercentageOfPopulationInfected
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC

--Looking at country with highest deaths per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAK THINGS DOWN BY CONTINENT
--Looking at continent with highest deaths
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Population vs. Vaccinations using CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinatiions, RollingPeopleVaccinated) AS
(
SELECT d.continent,d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location 
ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS d
JOIN CovidVaccination AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent,d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations as numeric)) OVER (PARTITION BY d.location 
ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS d
JOIN CovidVaccination AS v
ON d.location = v.location AND d.date = v.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW ViewPercentagePopulationVaccinated AS 
SELECT d.continent,d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations as numeric)) OVER (PARTITION BY d.location 
ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS d
JOIN CovidVaccination AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT * FROM ViewPercentagePopulationVaccinated

