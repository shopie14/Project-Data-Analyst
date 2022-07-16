select * from PortofolioProjects..CovidDeaths
where continent is not null
order by 3,4 

--select * from PortofolioProjects..CovidVaccinations
--order by 3,4

-- Select Data the we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population 
from PortofolioProjects..CovidDeaths
where continent is not null
order by 1,2 

-- Looking Total Cases Vs Total Deaths
select location, date,population, total_cases, total_deaths, (total_cases/population)*100 PercentPopulationInfected
from PortofolioProjects..CovidDeaths
where location = 'Australia'
and continent is not null
order by 3,4 

-- Looking at Countries with Highest Infection Rate Compared to Population 
select location, population, max(total_cases) HighestInfectionCount, max((total_cases/population)*100) PercentPopulationInfected
from PortofolioProjects..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest  Death Count per Population 
select Location, max(cast(total_deaths as int)) TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Let's break thing down by continent 
select continent, max(cast(total_deaths as int)) TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Global Nurmbers
select date, sum(new_cases) TotalNewCasesCount
from PortofolioProjects..CovidDeaths
where continent is null
group by date
order by 1,2 desc

select sum(new_cases) TotalNewCasesCount, sum(cast(new_deaths as int)) TotalNewDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from PortofolioProjects..CovidDeaths
where continent is not null
-- group by date
order by 1,2 desc


-- Table of CovidVaccinations
-- Looking at Total Population Vs Vaccinations

select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by Dea.location order by dea.location, dea.date) RollingPeopleVaccinated 
-- (RollingPeopleVaccinated/population)*100
from PortofolioProjects..CovidDeaths Dea
join PortofolioProjects..CovidVaccinations Vac
	on Dea.location = vac.location
	and Dea.date = vac.date
-- where Dea.continent is not null
order by 2, 3

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by Dea.location order by dea.location, dea.date) RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortofolioProjects..CovidDeaths Dea
join PortofolioProjects..CovidVaccinations Vac
	on Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by Dea.location order by dea.location, dea.date) RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortofolioProjects..CovidDeaths Dea
join PortofolioProjects..CovidVaccinations Vac
	on Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to Store data for later visualizations

create view PercentPopulationVaccinated as
select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by Dea.location order by dea.location, dea.date) RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortofolioProjects..CovidDeaths Dea
join PortofolioProjects..CovidVaccinations Vac
	on Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent is not null
--order by 2, 3