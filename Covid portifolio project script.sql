SELECT *
From [PortifolioProject]..CovidDeaths
order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
From [PortifolioProject]..CovidDeaths
order by 1,2

--Looking at Total cases vs Total_deaths
--THe likelyhood of dying if you contact covid

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)) /(cast(total_cases as float))*100 as DeathPercentage
From PortifolioProject..CovidDeaths
--WHERE location like '%south africa%'
order by 1,2

--Looking at the total cases vs total population 
--shows what percentage of population got covid

Select Location, date, total_cases, Population, ((cast(total_cases as float))/Population)*100 as PercentPopulationInfection
From PortifolioProject..CovidDeaths
--WHERE location like '%south africa%'
order by 1,2

--Looking at countries with highest infection rate
Select Location,Population,  MAX(cast(total_cases as float)) as HighestInfectionCount, MAX((cast(total_cases as float))/Population)*100 as PercentPopulationInfection
From PortifolioProject..CovidDeaths
--WHERE location like '%south africa%'
Group by Location,population
order by PercentPopulationInfection DESC

--SHowing countries with highest death count per pepolation
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortifolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE continent is not NULL
Group by Location
order by TotalDeathCount DESC

--Reading deaths by continent 
--SHowing continent with highest death count per pepolation

Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortifolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE continent is not NULL
Group by continent
order by TotalDeathCount DESC

--LOOKING AT THE GLOBAL NUMBERS
Select SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, (SUM(cast(new_deaths as float)) /SUM(cast(new_cases as float))*100) as DeathPercentage
From PortifolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE continent is NULL
--Group by new_cases, new_deaths
order by 1,2

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated,

From PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualisations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

