select *
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Total Cases vs. Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2



-- Total Cases vs. Population
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, max((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as BigInt)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Highest Death Count per Continent
Select continent, MAX(cast(total_deaths as BigInt)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL numbers 
Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeaths$
Where continent is not null
--Where location like '%states%'
group by date
order by 1,2


-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as  VaccinatedPeopleRolling
 
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- TEMP TABLE

Create Table #PercentPopVacc
(
Continent nvarchar(255),
Location  nvarchar(255),
Date      datetime, 
Population numeric,
new_vaccinations numeric,
VaccinatedPeopleRolling numeric
)
Insert into #PercentPopVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as  VaccinatedPeopleRolling
 
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

