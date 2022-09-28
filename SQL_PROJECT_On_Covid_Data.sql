select *
from first_portfolio_project..CovidDeaths
where continent is not null
order by 3,4

--select *
--from first_portfolio_project..CovidVaccinations$
--order by 3,4

select location, date, total_cases,new_cases,total_deaths,population
from first_portfolio_project..CovidDeaths
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from first_portfolio_project..CovidDeaths
order by 1,2

--using where clause
select location, date, total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from first_portfolio_project..CovidDeaths
where location like'%india%' 
order by 1,2


--Looking at total case vs the population

select location, date,population,(total_cases/population)*100 as PercentageOfPopulationInfected
from first_portfolio_project..CovidDeaths
where location like '%india%'
order by 1,2


--looking at countries with hightest infection rate compare to population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulationInfected
from first_portfolio_project..CovidDeaths
--where location like '%india%'
group by location , population
order by PercentageOfPopulationInfected desc

--Showing Countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from first_portfolio_project..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc


--Let's Break thing down by Continent
-- rihght continental data

select location, max(cast(total_deaths as int)) as TotalDeathCount
from first_portfolio_project..CovidDeaths
--where location like '%india%'
where continent is null
group by location
order by TotalDeathCount desc

--wrong continental data
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from first_portfolio_project..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage --total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from first_portfolio_project..CovidDeaths
--where location like'%india%' 
where continent is not null
group by date
order by 1,2

--ex***********
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage --total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from first_portfolio_project..CovidDeaths
--where location like'%india%' 
where continent is not null
--group by date
order by 1,2

select*
from first_portfolio_project..CovidVaccinations

--let join covidDeath and covidVaccination

select*
from first_portfolio_project..CovidDeaths dea
join first_portfolio_project..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATION
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from first_portfolio_project..CovidDeaths dea
join first_portfolio_project..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--population vs vaccination
--use cte
with PopVsVAc (continent,location,date,population, new_vaccinations, RollingPeopleVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from first_portfolio_project..CovidDeaths dea
join first_portfolio_project..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinations/population)*100 as PercentagePeopleVaccinations
from PopVsVAc



--temp table
drop table if exists #PercentagePopulationVaccination

create table #PercentagePopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinations numeric
)

insert into #PercentagePopulationVaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from first_portfolio_project..CovidDeaths dea
join first_portfolio_project..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVaccinations/population)*100 as PercentagePeopleVaccinated
from #PercentagePopulationVaccination

---creating view to store data for data visuallisation

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from first_portfolio_project..CovidDeaths dea
join first_portfolio_project..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select*
from PercentPopulationVaccinated

