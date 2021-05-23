--1. 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortofolio..CovidDeaths
where continent is not null 
order by total_cases, total_deaths

--2. Total Death Count per continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From ProjectPortofolio..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortofolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- 4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortofolio..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Shoutout to Alex The Analyst for teaching me how to do this!
