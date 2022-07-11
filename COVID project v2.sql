SELECT * FROM [dbo].[CovidDeaths]
WHERE continent is not null


Select [location],date, total_cases, new_cases, total_deaths, population
From [dbo].[CovidDeaths]
order by 1,2


-- Looking at Total cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
where location = 'India'
order by 1,2
--shows the likelihood of dying if I contract COVID in India by time


--Looking at Total Cases Vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as Infected_population
From [dbo].[CovidDeaths]
where location = 'India'
order by 1,2
--shows the percentage of population that contracted COVID by time


--Looking at countries with highest infection rate vs population
Select location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as Infected_population
From [dbo].[CovidDeaths]
group by location, population
order by Infected_population DESC


--Looking at countries with highest death count vs population
Select location, MAX(CAST(total_deaths as INT)) as Total_death_count
From [dbo].[CovidDeaths]
WHERE continent is not null
group by location
order by Total_death_count DESC


--Highest death count vs continent
Select continent, SUM(CAST(new_deaths as INT)) as Total_death_count
From [dbo].[CovidDeaths]
WHERE continent is not null
group by continent
order by Total_death_count DESC


-- Showing continents with highest death counts per population

Select continent, SUM(population) as Total_continent_population, SUM(CAST(new_deaths as INT)) as Total_death_count
From [dbo].[CovidDeaths]
WHERE continent is not null
group by continent
order by Total_continent_population DESC, Total_death_count DESC


--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(CAST([new_deaths] as INT)) as total_deaths ,(SUM(CAST([new_deaths] as INT))/SUM(new_cases))*100 as Death_percentage
From [dbo].[CovidDeaths]
where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(CAST([new_deaths] as INT)) as total_deaths ,(SUM(CAST([new_deaths] as INT))/SUM(new_cases))*100 as Death_percentage
From [dbo].[CovidDeaths]
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

SELECT 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccination_till_date
FROM [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null --and dea.location = 'India'
order by 1,2,3


-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, total_vaccination_till_date)
As
(
SELECT 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccination_till_date
FROM [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null --and dea.location = 'India'
--order by 1,2,3
)
Select *, (total_vaccination_till_date/Population)*100 as vaccination_percentage_till_date 
from PopvsVac
--where Location = 'India'
order by 2,3



-- Creating view for storing data for visualization

Create view PercentPopulationVaccinated as
SELECT 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccination_till_date
FROM [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null --and dea.location = 'India'
--order by 1,2,3



Select * from PercentPopulationVaccinated