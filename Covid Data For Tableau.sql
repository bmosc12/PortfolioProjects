-- Queries used for Tableau

-- 1

-- Compare the two to make sure the numbers match.

Select Sum(cast(new_cases as bigint)) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, Sum(cast(new_deaths as bigint))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- The second is super close but includes the "International" location

--Select Sum(cast(new_cases as bigint)) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, Sum(cast(new_deaths as bigint))/Sum(new_cases)*100 as DeathPercentage
--From [Portfolio Project]..CovidDeaths
--where location = 'World'
--order by 1,2

-- 2

-- Get rid of a few oddball statistics
-- European countries are still in the data even after taking out 'European Union'

Select location, SUM(cast(new_deaths as bigint)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
Order by TotalDeathCount desc

-- 3

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- 4

Select location, population, date, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected desc



-- Vaccination Data

-- 5


Select dea.location, dea.population, dea.date, Max(vac.people_fully_vaccinated) as PeopleVaccinated, Max((vac.people_fully_vaccinated/dea.population))*100 as PercentPopulationVaccinated 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
Group by dea.location, dea.population, dea.date
--Order by date, location


-- Positive Test Rate

-- 6

Select location, date, cast(positive_rate as float) * 100 as PositivePercentage
From [Portfolio Project]..CovidVaccinations
Order by 1, 2

-- New Cases

-- 7

Select location, date, new_cases
From [Portfolio Project]..CovidDeaths
Order by 1, 2

-- Hospital and ICU Patients

-- 8

Select location, date, hosp_patients, icu_patients
From [Portfolio Project]..CovidDeaths
Order by 1, 2