SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
order by 3,4

/* SELECT *
FROM [Portfolio Project]..CovidVaccinations
order by 3,4 */

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths (per country)
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,  total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%' and continent is not null
order by 1,2


-- Looking at Total cases vs population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (Total_cases/population)*100 as CasePercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%' and continent is not null
order by 1,2


-- Looking at Countries with highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPolulationInfected
FROM [Portfolio Project]..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
Group by Location, Population
order by PercentPolulationInfected desc


-- Showing the countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break this down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
-- WHERE location like '%states%' and  
WHERE continent is not null
-- GROUP BY date
order by 1,2


--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join[Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vacinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join[Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- Order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- with temp table
-- DROP TAble if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join[Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- Order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualization

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join[Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- Order by 2,3

SELECT *
FROM PercentPopulationVaccinated