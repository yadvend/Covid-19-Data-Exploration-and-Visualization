SELECT * FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4
SELECT * FROM CovidProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--Selecting data we are going to be using

Select location, date, new_cases, total_cases, total_deaths, population 
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Analysing total_cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Analysing total_cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as PatientPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
--WHERE location = 'India'   
ORDER BY 1,2

--Analysing countries with Highest infection rate compared to population 
SELECT location, max(total_cases), population, max((total_cases/population))*100 as PatientPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
--WHERE location = 'India' 
GROUP BY location,population
ORDER BY 4 DESC

--Analysing countries with Highest death rate compared to population 
SELECT location, max(total_deaths) as TotalDeathCount, population, max((total_deaths/population))*100 as DeathRate_wrt_population
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY 4 DESC

--Analysing death count by continent
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidProject..CovidDeaths
WHERE continent is null
Group by location
ORDER BY 2 DESC

--we use location instead of continent because of ome anomalies

--Global
SELECT date, sum(new_cases) as NewCasesToday, sum(cast(new_deaths as int)) as NewDeathsToday
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

--analysing population vs total vaccination

Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations , SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location
, dea.Date) as TotalPeopleVacinated   -- ,(TotalPeopleVaccinated/population)*100
From CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vacc
On dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated

From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 

)
Select *, (TotalPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
 TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated

From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date

Select *, (TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 

