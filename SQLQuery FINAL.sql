Select *
From PortfolioProject_Updated..['Covid Deaths new]
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject_Updated..['Covid Vaccinations new]
--order by 3,4

-- Select Daata that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_Updated..['Covid Deaths new]
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,
CASE WHEN total_cases = 0 THEN NULL -- Handle division by zero
ELSE (total_deaths * 100) / total_cases -- Calculate Death Percentage
END AS Death_Percentage  
From PortfolioProject_Updated..['Covid Deaths new]
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date,  Population, total_cases, (total_cases/population) *100 AS PercentPopulationInfected
From PortfolioProject_Updated.. ['Covid Deaths new]
-- Where location like '%states%'
Where continent is not null
order by 1, 2


-- Looking at Counties with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 AS PercentPopulationInfected
From PortfolioProject_Updated.. ['Covid Deaths new]
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with the highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject_Updated.. ['Covid Deaths new]
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount  desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject_Updated.. ['Covid Deaths new]
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount  desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject_Updated.. ['Covid Deaths new]
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount  desc



-- GLOBAL NUMBERS

SELECT
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(new_cases), 0)
    END AS DeathPercentage
FROM
    PortfolioProject_Updated.. ['Covid Deaths new]
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100
From PortfolioProject_Updated.. ['Covid Deaths new] dea
Join PortfolioProject_Updated.. ['Covid Vaccinations new] vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 -- USE CTE (revisit this 1 hour 5 min in YT)

 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100
From PortfolioProject_Updated.. ['Covid Deaths new] dea
Join PortfolioProject_Updated.. ['Covid Vaccinations new] vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE (Figure out why this keeps getting error)

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject_Updated.. ['Covid Deaths new] dea
Join PortfolioProject_Updated.. ['Covid Vaccinations new] vac
 On dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

Select*, (RollingPeopleVaccinated/Population) * 100 
From #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100
From PortfolioProject_Updated.. ['Covid Deaths new] dea
Join PortfolioProject_Updated.. ['Covid Vaccinations new] vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 Select * 
 From PercentPopulationVaccinated