/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject...CovidDeaths
where continent is not null 
order by 1,2



-- 2. 


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject...CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income','Lower middle income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject...CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject...CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc