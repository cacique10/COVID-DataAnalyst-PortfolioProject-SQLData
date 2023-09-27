
select *
from dbo.CovidDeaths
where continent is not null
order by 3,4



-- select data we are going to use
select continent, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1, 2;


-- total cases vs total deaths (% deaths per cases),
-- % chance to die if infected
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from dbo.CovidDeaths
where location like '%brazil%'
and continent is not null
order by 1, 2;


-- total cases vs population, 
-- % of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths
where location like '%brazil%'
and continent is not null
order by 1, 2;


-- contries with highest infection rate compared to population
select location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;


--  death count PER CONTINENT
select continent, MAX(total_deaths) as totaldeathcount
from dbo.CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc;


-- continents with highest death count
select continent, MAX(total_deaths) as totaldeathcount
from dbo.CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc;



--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------


-- GLOBAL NUMBERS

-- total cases, deaths and deaths percentage worldwide
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_percentage
from dbo.CovidDeaths
where continent is not null
order by 1, 2;


-- USE CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100 from popvsvac;



--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------


-- create VIEW for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;