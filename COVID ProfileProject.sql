

select*
from CovidVaccination
order by 3,4

select *
from CovidDeaths
where continent is not null
order by 3,4

---we select data we're going to use

select location, date, total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

---looking at total case vs total death

select location, date, total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
from CovidDeaths
order by 1,2

---shows the likely hood of dying  one contact covid in united state and in Nigeria
select location, date, total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
from CovidDeaths
where location like '%state%'
order by 1,2

select location, date, total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
from CovidDeaths
where location like '%Nigeria%'
order by 1, 2

---looking at total case vs population
select  location, date, total_cases,population,(total_cases/population)* 100 as CasePerPopulation
from CovidDeaths
where location like '%Nigeria%'
order by 1,2

---what country have the highest infection rate compired to population
select location,population, max(total_cases)as mostinfectedCountry, max(total_cases/population)* 100 as CasePerPopulation
from CovidDeaths
Group by location, population
order by  CasePerPopulation desc

--- showingcountry with the higest death count per population
select location, max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths
group by location
order by  TotalDeathCount desc

---showing only countries with the highest death count per population
select location, max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by  TotalDeathCount desc
---{united state is the highest}

---Breaking it down by continents
select continent, max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by  TotalDeathCount desc
---{This shows that North America is the highest}

select location, max(cast(total_deaths as int))as TotalDeathCount, location
from CovidDeaths
where continent is  null
group by location
order by  TotalDeathCount desc
---{this shows that Europe is the highest}

---GLOBAL NUMBER
select sum(new_cases) as total_cases
,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int)) 
/sum(new_cases)  * 100 as DeathPersentage
from CovidDeaths
where continent is not null
order by 1,2


---joining both tables
select*
from CovidDeaths Dea
join Covidvaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date

---looking at total vaccination vs population

select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
from CovidDeaths Dea
join Covidvaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null and Vac.new_vaccinations is not null
order by 2,3

select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location)
from CovidDeaths Dea
join Covidvaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null and Vac.new_vaccinations is not null
order by 2,3
---showing the vaccination partitioned by location.


select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location  order by Dea.location, Dea.date
) as rollingPeoplevaccination
from CovidDeaths Dea
join Covidvaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null and Vac.new_vaccinations is not null
order by 2,3

---using CTE

with PopVsVas(continent,location,date,population,New_vaccinations,rollingPeoplevaccination)
as
(
select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location  order by Dea.location, Dea.date
) as rollingPeoplevaccination
from CovidDeaths Dea
join Covidvaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null and Vac.new_vaccinations is not null
--order by 2,3
)
select*,(rollingPeoplevaccination/population)*100
from PopVsVas

---Tempt table
drop table if exists #PercentagePoulationvaccinated#
create table #PercentagePoulationvaccinated#
(
continent varchar(225),
location varchar(225),
Date datetime,
population numeric,
new_vaccination numeric,
rollingPeoplevaccination numeric
)

insert into #PercentagePoulationvaccinated#
select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location  order by Dea.location, Dea.date
) as rollingPeoplevaccination
from CovidDeaths Dea
join Covidvaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null and Vac.new_vaccinations is not null 
---order by 2,3 
select*,(rollingPeoplevaccination/population)*100
from #PercentagePoulationvaccinated#

---creating views to store data for visualization
create view PercentagePoulationvaccinate as
select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location  order by Dea.location, Dea.date
) as rollingPeoplevaccination
from CovidDeaths Dea
join Covidvaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null and Vac.new_vaccinations is not null 
---order by 2,3 

select *
from PercentagePoulationvaccinate