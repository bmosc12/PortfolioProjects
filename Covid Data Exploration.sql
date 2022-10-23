Select *
From [Portfolio Project]..CovidDeaths
order by 3, 4

Select *
From [Portfolio Project]..CovidVaccinations
order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population go Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
-- Where location like '%states%'
order by 1, 2

-- Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Showing Countries with highest death count per population

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

Select location, population, MAX(cast(total_deaths as bigint)) as TotalDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDied
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationDied desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Shows death count by continent
Select continent, 
	Sum(Case When date = '2022-10-18 00:00:00.000'
		Then total_deaths Else 0 End) as Deaths
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
Order by Deaths desc

-- Potentially take World and International out of here for charting
Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
And location NOT LIKE '%income%'
Group by location
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(cast(new_cases as bigint)) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
group by date 
order by 1, 2

-- Using the world location
--Select date, cast(total_cases as bigint) as total_cases, cast(total_deaths as bigint) as total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From [Portfolio Project]..CovidDeaths
--where location = 'World'
--group by date, total_cases, total_deaths
--order by 1, 2

-- Quick Join check
Select *
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidDeaths vac
	On dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
, SUM(cast(vac.new_people_vaccinated_smoothed as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (continent, location, date, population, new_people_vaccinated_smoothed, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
, SUM(cast(vac.new_people_vaccinated_smoothed as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
From PopvsVac


-- TEMP TABLE

Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_people_vaccinated_smoothed nvarchar(255),
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
, SUM(cast(vac.new_people_vaccinated_smoothed as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercent
From #PercentPopulationVaccinated

-- Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
, SUM(cast(vac.new_people_vaccinated_smoothed as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null


Create View WorldDeaths as
Select date, SUM(cast(new_cases as bigint)) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
group by date

