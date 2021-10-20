SELECT *
From portfolio..CovidDeaths
Where continent is not NULL
order by 3,4

-- SELECT *
-- From portfolio..CovidVaccinations
-- order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
From portfolio..CovidDeaths
Where location like '%kingdom%'
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio..CovidDeaths
Where location like '%kingdom%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population has covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From portfolio..CovidDeaths
Where location like '%kingdom%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPercentage
From portfolio..CovidDeaths
Where continent is not NULL
Group by location, population
order by InfectedPercentage DESC

--Showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
From portfolio..CovidDeaths
Where continent is not NULL
Group by location
order by TotalDeathCount DESC

--Broken down by continent
--Showing the continents with highest death count

SELECT [continent], MAX(total_deaths) as TotalDeathCount
From portfolio..CovidDeaths
Where continent is not NULL
Group by [continent]
order by TotalDeathCount DESC

-- Global numbers

SELECT  SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths,  SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
From portfolio..CovidDeaths
Where continent is not NULL
order by 1,2

--Total population vs vaccinations

SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--Use CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
where dea.continent is not NULL
)
SELECT * , (RollingPeopleVaccinated/ population)*100
from PopvsVac


--Temp table

Drop table if exists #PercentPopVaccinated
Create TABLE #PercentPopVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

Insert into #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
where dea.continent is not NULL

SELECT * , (RollingPeopleVaccinated / population)*100
from #PercentPopVaccinated


-- Creating view to store data for visualisations

Create View PercentPopVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
where dea.continent is not NULL



Select *
From PercentPopVaccinated

--Queries for Tableau

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portfolio..CovidDeaths
where continent is not null 
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
