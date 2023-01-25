
select *
from portfolioProject..covidDeaths$
where continent is not null
order by 3,4 
--select *
--from portfolioProject..[covid-vaccines]
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..covidDeaths$ 
where continent is not null
order by 1,2

-- we will be checking for total number of cases vs total deaths.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject..covidDeaths$
where continent is not null
order by 1,2 


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject..covidDeaths$
where continent is not null
where location like '%Brazil%'
order by 1,2 

-- total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from portfolioProject..covidDeaths$
where location like '%Brazil%'
where continent is not null
order by 1,2

--highest infection rate / pop

select location, population, Max(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From portfolioProject..covidDeaths$
where continent is not null
group by location, population
order by InfectedPercentage desc

--show country with highest deathcount per population
select location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentofDead
From portfolioProject..covidDeaths$
where continent is not null
group by location, population
order by HighestDeathCount desc 

select location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population))*100 as PercentofDead
From portfolioProject..covidDeaths$
where continent is not null
group by location, population
order by PercentofDead desc

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from portfolioProject..covidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- by continent 

select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From portfolioProject..covidDeaths$
where continent is null
group by location
order by TotalDeathCount desc 

--continents with highest death counts per population

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCountPerContinent
from portfolioProject..covidDeaths$
where continent is not null 
group by continent 
order by TotalDeathCountPerContinent desc 

-- global numbers
		--sum of new cases everyday
select date, sum(new_cases)
from portfolioProject..covidDeaths$
where continent is not null
group by date
order by 1,2 
	
		--sum of total cases 
select date, sum(total_cases)
from portfolioProject..covidDeaths$
where continent is not null
group by date
order by 1,2

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from portfolioProject..covidDeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from portfolioProject..covidDeaths$
where continent is not null
order by 1,2

--covid vaccinations
-- joining tables and checking if joined correctly 
select *
from portfolioProject..covidDeaths$ dea
join portfolioProject..[covid-vaccines] vac
	on dea.location = vac.location
	and dea.date = vac.date

-- total pop vs vaccination use cte
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from portfolioProject..covidDeaths$ dea
join portfolioProject..[covid-vaccines] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from portfolioProject..covidDeaths$ dea
join portfolioProject..[covid-vaccines] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--create view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from portfolioProject..covidDeaths$ dea
join portfolioProject..[covid-vaccines] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


--to view V V
select *
from dbo.PercentPopulationVaccinated

