
SELECT *
FROM PortfolioProject00..CovidDeaths
ORDER BY 3, 4;



select * 
from PortfolioProject00..CovidDeaths
order by 3, 4;



-- Selecting Data that we need 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject00..CovidDeaths
Order by 1, 2

-- Total Cases vs Total Deaths

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject00..CovidDeaths
where location like 'United States'
Order by 1,2



-- Total Cases vs Population

Select Location, date, population, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject00..CovidDeaths
where location = 'United States'
Order by 1, 2



Select *
From PortfolioProject00..CovidDeaths
Where continent is not null 
order by 3, 4



-- Selecting Data that we need 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject00..CovidDeaths
Where continent is not null 
order by 1, 2



-- Total Cases vs Total Deaths for a particular country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject00..CovidDeaths
WHERE location = 'United States'
  AND continent IS NOT NULL
ORDER BY Location, date;



-- Total Cases vs Population

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject00..CovidDeaths
order by 1, 2



-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject00..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject00..CovidDeaths
\Where continent is not null 
Group by Location
order by Total_Death_Count desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject00..CovidDeaths
Where continent is not null 
Group by continent
order by Total_Death_Count desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject00..CovidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
  ROUND((SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / CAST(dea.population AS FLOAT)) * 100, 3) AS percentage
FROM PortfolioProject00..CovidDeaths dea
JOIN PortfolioProject00..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
  FROM
    PortfolioProject00..CovidDeaths dea
  JOIN
    PortfolioProject00..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL
)
SELECT
  *,
  ROUND((RollingPeopleVaccinated / CAST(Population AS FLOAT)) * 100, 3) AS Percentage
FROM
  PopvsVac;




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
  Continent NVARCHAR(255),
  Location NVARCHAR(255),
  Date DATETIME,
  Population NUMERIC,
  New_vaccinations NUMERIC,
  RollingPeopleVaccinated BIGINT
);

INSERT INTO #PercentPopulationVaccinated
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
  PortfolioProject00..CovidDeaths dea
JOIN
  PortfolioProject00..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date;

SELECT
  *,
  (RollingPeopleVaccinated / Population) * 100 AS Percentage
FROM
  #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated1 AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject00..CovidDeaths dea
JOIN
    PortfolioProject00..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;



Select *
From PercentPopulationVaccinated1