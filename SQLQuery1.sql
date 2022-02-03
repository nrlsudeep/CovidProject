use PortfolioProject;

select * 
from CovidDeaths
order by 3,4
;
select * --sum(cast(new_vaccinations as bigint))
from CovidVaccinations
where location = 'canada'
--group by location
order by 3,4
;

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2 
;
-- Looking at death percentage
-- likelihood of dying if got covid in Canada
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%canada%'
order by 1,2 
;


-- What percentage of population got covid
select location, date,population, total_cases, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%canada%'
order by 1,2 
;


-- countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%canada%'
group by location, population
order by  PercentPopulationInfected desc
;

-- countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by  TotalDeathCount desc
;

--  BREAK THINGS DOWN BY CONTINENT ------------------------------------
-- Continents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by  TotalDeathCount desc
;

--Global Numbers
Select  sum(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2 
;

--Joining Two Tables  
--cumulative sum 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on  dea.location = vac. location	
	and dea.date =	vac.date
where dea.continent is not null
order by 2, 3
	;

-- vaccination percentage
-- TWO MEthods to use the new column and add/sum/max that column)
-- 1. USING CTE  (no of columns on out and in should be same)

With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on  dea.location = vac. location	
	and dea.date =	vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
from popvsvac	
--where location = 'Canada'   --this is not correct vaccniation population is greater than country population)


--2. Create TEMP TABLE
--Create Table
Drop table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
continent varchar(255),
location varchar (255),
date datetime,
population bigint,
New_Vaccinations  bigint,
RollingPeopleVaccinated float
)
insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on  dea.location = vac. location	
	and dea.date =	vac.date
where dea.continent is not null

--order by 2, 3
Select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated
where location = 'Canada'   --this is not correct vaccniation population is greater than country population (people_fully_vaccinated column shoud be used)


-- Creating a View to store data for visulization

create view PercentPeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on  dea.location = vac. location	
	and dea.date =	vac.date
where dea.continent is not null


Select *
From	PercentPeopleVaccinated