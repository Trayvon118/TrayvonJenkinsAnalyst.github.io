SELECT *
FROM PorfolioProject..CovidDeaths1
ORDER BY 3,4;

SELECT *
FROM PorfolioProject..CovidVaccinations1
ORDER BY 3,4;

--Select the data that we are using

SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths1
ORDER BY 1,2

---Total Cases vs Total Deaths (USA)

SELECT  location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)* 100 AS Deathpct
FROM PorfolioProject..CovidDeaths1
WHERE location like '%states%'
ORDER BY 1,2

----Total Cases vs Populations----(pct who got Covid)

SELECT  location, date, total_cases, population, (total_cases*1.0/population)* 100 AS Infectedpct
FROM PorfolioProject..CovidDeaths1
--WHERE location like '%states%'
ORDER BY 1,2

---Highest Infected Rate TO Population

SELECT  location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases*1.0/population))* 100 AS Infectedpct
FROM PorfolioProject..CovidDeaths1
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY Infectedpct DESC

---Countries with Highest Death Count per Population

SELECT  location,  MAX(total_deaths) as TotalDeathCount
FROM PorfolioProject..CovidDeaths1
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT  location,  MAX(total_deaths) as TotalDeathCount
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

---BY continent
SELECT  location,  MAX(total_deaths) as TotalDeathCount
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


---Global Numbers

SELECT  date, SUM(new_cases) AS GlobalCases, SUM(new_deaths) AS GlobalDealths, SUM(new_deaths*1.0)/SUM(new_cases)*100 AS GlobalDeathpct
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

---Total Global Numbers
SELECT SUM(new_cases) AS GlobalCases, SUM(new_deaths) AS GlobalDealths, SUM(new_deaths*1.0)/SUM(new_cases)*100 AS GlobalDeathpct
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NOT NULL
ORDER BY 1,2


------Join Tables Total Pop. VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths1 AS dea
JOIN PorfolioProject..CovidVaccinations1 AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---Create CTE

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths1 AS dea
JOIN PorfolioProject..CovidVaccinations1 AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated*1.0/Population)*100
FROM PopvsVac

---Create TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths1 AS dea
JOIN PorfolioProject..CovidVaccinations1 AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated*1.0/Population)*100
FROM #PercentPopulationVaccinated



---CREATING VIEW to store data for later Visualiztions

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths1 AS dea
JOIN PorfolioProject..CovidVaccinations1 AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


---CREATING VIEW

CREATE VIEW GlobalCovidImpact AS
SELECT SUM(new_cases) AS GlobalCases, SUM(new_deaths) AS GlobalDealths, SUM(new_deaths*1.0)/SUM(new_cases)*100 AS GlobalDeathpct
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NOT NULL


---DROP VIEW 

DROP VIEW IF EXISTS GlobalCovidImpact;

----CREATING VIEW

CREATE VIEW ContinentDeathCount AS
SELECT  location,  MAX(total_deaths) as TotalDeathCount
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NULL
GROUP BY location
---ORDER BY TotalDeathCount DESC



---Tables to add to an Excel File (Tableau Public)

SELECT SUM(new_cases) AS GlobalCases, SUM(new_deaths) AS GlobalDealths, SUM(new_deaths*1.0)/SUM(new_cases)*100 AS GlobalDeathpct
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NOT NULL;

SELECT  location,  MAX(total_deaths) as TotalDeathCount
FROM PorfolioProject..CovidDeaths1
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT  location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases*1.0/population))* 100 AS Infectedpct
FROM PorfolioProject..CovidDeaths1
GROUP BY location, population
ORDER BY Infectedpct DESC

SELECT  location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases*1.0/population))* 100 AS Infectedpct
FROM PorfolioProject..CovidDeaths1
GROUP BY location, population, date
ORDER BY Infectedpct DESC