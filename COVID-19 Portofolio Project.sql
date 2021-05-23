-- Shows all the data from CovidDeaths table
SELECT *
FROM ProjectPortofolio..CovidDeaths
ORDER BY 3,4

-- Shows some data from CovidDeaths table ordered by location and date
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortofolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Percentage of Total Deaths vs Total Cases in Indonesia, Order by highest death percentage
-- Shows likelihood of dying if you caught Covid-19 in Indonesia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectPortofolio..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY DeathPercentage DESC

-- Percentage Total Cases vs Total Population in Indonesia from time to time
-- Shows what percentage of population contracted Covid-19 in Indonesia
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM ProjectPortofolio..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY date

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM ProjectPortofolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortofolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continent with the highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortofolio..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Numbers for Cases, Deaths, and Death Percentage per day in 2020
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProjectPortofolio..CovidDeaths
WHERE continent is not null
AND YEAR(date)='2020'
Group by date
Order by date

-- Looking at Total Population in Indonesia vs Vaccinations
-- How many people in Indonesia has been vaccinated?
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as Total_Vaccinations_PerDay
FROM ProjectPortofolio..CovidDeaths as dea
JOIN ProjectPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'Indonesia'
ORDER BY dea.date

-- Percentage of population in Indonesia that have been vaccinated
-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortofolio..CovidDeaths as dea
JOIN ProjectPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'Indonesia'
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as Percent_Total_Vaccinations
FROM PopvsVac

-- Temporal Table
DROP Table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortofolio..CovidDeaths as dea
JOIN ProjectPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'Indonesia'

SELECT *, (RollingPeopleVaccinated/Population)*100 as Percent_Total_Vaccinations
FROM #PercentPopulationVaccinated

-- Views
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortofolio..CovidDeaths as dea
JOIN ProjectPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'Indonesia'

SELECT *
FROM PercentPopulationVaccinated


-- Big thanks to Alex The Analyst for teaching me how to do this!
