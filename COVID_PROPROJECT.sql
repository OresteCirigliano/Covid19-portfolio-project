SELECT *
FROM Covid_portfolio_project..Covid_Deaths$
ORDER BY 3,4



SELECT *
FROM Covid_portfolio_project..Covid_Deaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--select * from Covid_portfolio_project..Covid_Deaths$ order by 3,4

--select *
--from Covid_portfolio_project..Covid_Vaccinations$
--order by 3,4

--SELECT DATA THAT I'AM GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
From Covid_portfolio_project..Covid_Deaths$
WHERE continent IS NOT NULL
order by 1,2


-- LOCKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID 19 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From Covid_portfolio_project..Covid_Deaths$
where location like '%united k%'
and continent IS NOT NULL
order by 1,3 desc

--LOOCKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentage_population_infected
From Covid_portfolio_project..Covid_Deaths$
where location like '%united k%'
order by 1,2

--Loocking at Countries with HIGHEST INFECTION RATE compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Percentage_population_infected
From Covid_portfolio_project..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP by location, population
order by Percentage_population_infected desc

--Showing Contries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From Covid_portfolio_project..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP by location
order by TotalDeathCount desc

--Showing Continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From Covid_portfolio_project..Covid_Deaths$
WHERE continent IS not NULL
GROUP by continent
order by TotalDeathCount desc

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_portfolio_project..Covid_Deaths$ 
where continent is not null
--Group by date
order by 1,2

-- Looking Total Population vs Vaccinations

----CREATE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_portfolio_project..Covid_Deaths$ dea
JOIN Covid_portfolio_project..Covid_Vaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

----CREATE TEMP TABEL
drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_portfolio_project..Covid_Deaths$ dea
JOIN Covid_portfolio_project..Covid_Vaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- create View to store data for late visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
FROM Covid_portfolio_project..Covid_Deaths$ dea
JOIN Covid_portfolio_project..Covid_Vaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated
