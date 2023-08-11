--SELECT * 
--FROM PortfolioProject..CovidDeaths$
--Order by 3,4

SELECT *
FROM [PortfolioProject].[dbo].[CovidVaccinations$]
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS PROBABILITY OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY(DEATH-PERCENTAGE)

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
Where location like '%Afghan%'
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT Location, date, total_cases,population, (total_cases/population)*100 as CaughtPercentage
FROM PortfolioProject.dbo.CovidDeaths$
Where location like '%Afghan%'
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location,population, MAX(total_cases) AS HIGHEST_NO_OF_CASES, MAX((total_cases/population))*100 as Percentage_OF_INFECTED
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%Afghan%'
GROUP BY location, population
ORDER BY 4 DESC


--LOOKING FOR COUNTRIES WITH HIGHEST DEATH RATE PER POPULATION

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount,population, (total_deaths/population)*100 as PERCENTAGE
FROM PortfolioProject.dbo.CovidDeaths$
Where continent is not null
GROUP BY location, population, total_deaths
ORDER BY 4 desc

--Lets break things down by continent

SELECT Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
Where continent is not null
GROUP BY Continent
ORDER BY 2 DESC


-- Showing continents with the highest death count per population

SELECT Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
Where continent is not null
GROUP BY Continent
ORDER BY 2 DESC




-- GLOBAL NUMBERS 
SELECT  date,SUM(new_cases) as globalcases, SUM(cast(new_deaths as int)) as globaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercent
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
Group By date 
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION 

SELECT dea.continent, dea.location, dea.date, dea.population, vsc.new_vaccinations
, SUM(CONVERT(INT, vsc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS ROLLINGADD
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vsc
	ON dea.location = vsc.location
	and dea.date = vsc.date
WHERE dea.continent is not null
order by 2,3





--USING CTE

WITH PopvsVsc (Continent, Location, Date, Population, New_Vaccinations, ROLLINGADD)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vsc.new_vaccinations
, SUM(CONVERT(INT, vsc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS ROLLINGADD
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vsc
	ON dea.location = vsc.location
	and dea.date = vsc.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (ROLLINGADD/Population)*100 
FROM PopvsVsc


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ROLLINGADD numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vsc.new_vaccinations
, SUM(CONVERT(INT, vsc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS ROLLINGADD
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vsc
	ON dea.location = vsc.location
	and dea.date = vsc.date
--WHERE dea.continent is not null
--order by 2,3
SELECT *, (ROLLINGADD/POPULATION) * 100
FROM #PercentPopulationVaccinated


































