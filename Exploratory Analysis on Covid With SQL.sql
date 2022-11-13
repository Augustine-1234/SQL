SELECT * FROM portfolio.coviddeaths_csv;
select * from portfolio.covidvaccinations_csv;

-- lets select data we'll be using

select location,continent,date,total_cases,new_cases,total_deaths,population
from portfolio.coviddeaths_csv where continent is not null order by 1;


-- Looking at the Total cases vs Total Deaths based on Africa

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as
DeathPecentage
from portfolio.coviddeaths_csv where location like '%Africa%'
order by 1

-- Looking at Total cases vs Population
-- Show what percentage of Population got Covid

select location,date,total_cases,population,(total_cases/population)*100
as Populated_per_covid
from portfolio.coviddeaths_csv where continent is not null order by 1;

-- Looking at Countries with Highest Infected Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentPopulatedInfected
from portfolio.coviddeaths_csv 
where continent is not null
group by location,population
order by PercentPopulatedInfected desc;

-- Showing Countries with Highest Death Count Per Location
-- Cast was use because total_deaths was a varchar and i intended to convert to float to get
-- the approprate count

 select location,max(cast(total_deaths  as float))as TotalDeathCount
from portfolio.coviddeaths_csv
where continent is not null
group by location
order by TotalDeathCount desc;

-- Showing Continent with Highest Death Count Per Location
select continent,max(cast(total_deaths  as float))as TotalDeathCount
from portfolio.coviddeaths_csv
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global number

select date, sum(new_cases) as total_cases,sum(cast(new_deaths as float)) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from portfolio.coviddeaths_csv
where continent is not null
-- group by date
order by 1

-- Looking at Total Population Vs Vaccination
-- Use cte
with PopVsVas (continent,location,date,population,new_vaccinations_smoothed,Part_location) as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations_smoothed,
sum(cast(vac.new_vaccinations_smoothed as float)) over (partition by dea.location order by dea.location,dea.date) as Part_location
 from 
portfolio.coviddeaths_csv as dea
join portfolio.covidvaccinations_csv as vac
  on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null)
-- order by 2,3)
 select *,(Part_location/population)* 100 as Percent_Vac_Population from PopVsVas;

create view Percent_Vac_Population as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations_smoothed,
sum(cast(vac.new_vaccinations_smoothed as float)) over (partition by dea.location order by dea.location,dea.date) as Part_location
 from 
portfolio.coviddeaths_csv as dea
join portfolio.covidvaccinations_csv as vac
  on dea.location = vac.location
where dea.continent is not null

