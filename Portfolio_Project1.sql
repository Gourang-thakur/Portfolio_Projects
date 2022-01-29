select *
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..covid_vaccination
--order by 3,4

--select Data that we are going to be using 

select location,date,total_cases,new_cases,total_deaths,population
from covid_deaths
where continent is not null
order by 1,2

--Looking at Total Cases VS Total Deaths 
--showing the recent death percentage of your country 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%india%'
order by 1,2


--Looking at total cases VS Population 
--showing infected percentage of covid 

select location,date,population,total_cases,(total_cases/population)*100 as infected_percentage
from covid_deaths
---where location like '%india%'
where continent is not null
order by 1,2

---Looking at countries with highest infected rate compared to population

select location,population,MAX(total_cases),max((total_cases/population))*100 as infected_percentage
from covid_deaths
---where location like '%india%'
where continent is not null
group by location,population
order by infected_percentage desc


---showing countries highest death count per population

select location , max(cast(total_deaths as int)) as maximum_deaths
from covid_deaths
---where location like '%india%'
where continent is not null
group by location,population
order by maximum_deaths desc

---LET's BREAK THINGS DOWN BY CONTINENT

select continent , max(cast(total_deaths as int)) as maximum_deaths
from covid_deaths
---where location like '%india%'
where continent is not null
group by continent
order by maximum_deaths desc


---showing the continent with highest death count 

select continent , max(cast(total_deaths as int)) as maximum_deaths
from covid_deaths
---where location like '%india%'
where continent is not null
group by continent
order by maximum_deaths desc


---GLOBLE NUMBERS




select date,sum(new_cases)as total_cases, sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid_deaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2


---total calculate globle


select sum(new_cases)as total_cases, sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid_deaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


---Looking at total population VS Vaccination



  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
  ,--( rolling_people_vaccinated/population)*100
 from PortfolioProject..covid_deaths dea
 join PortfolioProject..covid_vaccination vac
  on vac.location=dea.location
  and vac.date=dea.date
  where dea.continent is not null
  order by 2,3



  --USING CTE


  with popvsvac (continent,location,date, population,new_vaccination,rolling_people_vaccinated)
  as
  (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
  
  from PortfolioProject..covid_deaths dea
 join PortfolioProject..covid_vaccination vac
  on vac.location=dea.location
  and vac.date=dea.date
  where dea.continent is not null
 -- order by 2,3
  )

  select*, (rolling_people_vaccinated/population)*100
  from popvsvac



---temp tables
drop table if exists #percent_people_vaccinated
create table #percent_people_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric ,
rolling_people_vaccinated numeric

)
insert into #percent_people_vaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
  ,--( rolling_people_vaccinated/population)*100
 from PortfolioProject..covid_deaths dea
 join PortfolioProject..covid_vaccination vac
  on vac.location=dea.location
  and vac.date=dea.date
  where dea.continent is not null
  --order by 2,3


    select*, (rolling_people_vaccinated/population)*100
  from #percent_people_vaccinated


  ----creating views for data to store for further visualization 


  create view #percent_people_vaccinated as
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
  ,--( rolling_people_vaccinated/population)*100
 from PortfolioProject..covid_deaths dea
 join PortfolioProject..covid_vaccination vac
  on vac.location=dea.location
  and vac.date=dea.date
  where dea.continent is not null
  --order by 2,3


  select *
  from covid_vaccinationed