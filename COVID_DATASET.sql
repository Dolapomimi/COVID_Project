SELECT *
FROM Covid_Dataset..CovidVaccinations

SELECT *
FROM Covid_Dataset..CovidDeaths
WHERE continent IS NOT NULL 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Dataset..CovidDeaths


---Total cases VS Total Death
--- Shows the percentage of dying if contracting the virus in your country
SELECT location, date, total_cases, total_deaths, ROUND ((total_deaths/total_cases)*100,2) AS death_percentage
FROM Covid_Dataset..CovidDeaths
WHERE location = 'Nigeria'

--- Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_percentage
FROM Covid_Dataset..CovidDeaths
---WHERE location = 'Nigeria'

--- Countries with the highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PopuluationInfected_per
FROM Covid_Dataset..CovidDeaths
GROUP BY location, population
ORDER BY PopuluationInfected_per DESC

--- Countries with the Highest death count per Location

SELECT location,  MAX(cast(total_deaths as INT)) as highestDeathCount
FROM Covid_Dataset..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highestDeathCount DESC

--- Countries with the Highest death count by continent

SELECT continent,  sum(cast(new_deaths as INT)) as TotalDeathCount
FROM Covid_Dataset..CovidDeaths
WHERE continent IS  not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--- Total death count

SELECT sum(cast(new_deaths as INT)) as TotalDeathCount
FROM Covid_Dataset..CovidDeaths
WHERE continent IS  not NULL

--- percentage of death to cases

SELECT date, sum(new_cases) as TotalCase, sum(cast(new_deaths as INT)) as TotalDeathCount, 
sum(cast(new_deaths as INT))/sum(new_cases)*100 as deathPercentage
FROM Covid_Dataset..CovidDeaths
WHERE continent IS  not NULL
GROUP BY date
ORDER BY 1,2

--REMOVING DATE

SELECT  sum(new_cases) as TotalCase, sum(cast(new_deaths as INT)) as TotalDeathCount, 
sum(cast(new_deaths as INT))/sum(new_cases)*100 as deathPercentage
FROM Covid_Dataset..CovidDeaths
WHERE continent IS  not NULL
---GROUP BY date
ORDER BY 1,2


--- Total population vs vaccination
---Join both tables

SELECT dea.continent, dea.location, dea.date population, new_vaccinations, sum(cast(new_vaccinations as int)) OVER (Partition by dea.location  order by dea.location,dea.date) as peoplevaccinated
FROM Covid_Dataset..CovidDeaths Dea
INNER JOIN Covid_Dataset..CovidVaccinations Vac
ON Dea.location = Vac.location and 
   Dea.date = Vac.date
WHERE dea.continent IS  not NULL
order by 2,3

---USING CTE to calculate the percentage of vaccinated people per population

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, peoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, sum(cast(new_vaccinations as int)) OVER (Partition by dea.location  order by dea.location,dea.date) as peoplevaccinated
FROM Covid_Dataset..CovidDeaths Dea
INNER JOIN Covid_Dataset..CovidVaccinations Vac
ON Dea.location = Vac.location and 
   Dea.date = Vac.date
WHERE dea.continent IS  not NULL
)
SELECT *, (peoplevaccinated/population)*100 AS per_peoplevacc
FROM pop_vs_vac


---Using Temp Tables

--- Max percentage of vaccinated people per population by location

Drop Table if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date Datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric

)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, sum(cast(new_vaccinations as int)) OVER (Partition by dea.location  order by dea.location,dea.date) as peoplevaccinated
FROM Covid_Dataset..CovidDeaths Dea
INNER JOIN Covid_Dataset..CovidVaccinations Vac
ON Dea.location = Vac.location and 
   Dea.date = Vac.date
WHERE dea.continent IS  not NULL


SELECT continent, location, population,new_vaccinations, max(peoplevaccinated/population)*100 as total_per
FROM #PercentPopulationVaccinated
Group by continent, location, population, new_vaccinations


---Creating Views for visualizations

Create View PercentPopulationVaccinated 
AS 
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, sum(cast(new_vaccinations as int)) OVER (Partition by dea.location  order by dea.location,dea.date) as peoplevaccinated
FROM Covid_Dataset..CovidDeaths Dea
INNER JOIN Covid_Dataset..CovidVaccinations Vac
ON Dea.location = Vac.location and 
   Dea.date = Vac.date
WHERE dea.continent IS  not NULL

Select* from PercentPopulationVaccinated

Create View Global_death_Percentage
AS
SELECT  sum(new_cases) as TotalCase, sum(cast(new_deaths as INT)) as TotalDeathCount, 
sum(cast(new_deaths as INT))/sum(new_cases)*100 as deathPercentage
FROM Covid_Dataset..CovidDeaths
WHERE continent IS  not NULL
---GROUP BY date
--ORDER BY 1,2


CREATE VIEW Country_total_deaths
AS
SELECT location,  MAX(cast(total_deaths as INT)) as highestDeathCount
FROM Covid_Dataset..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY highestDeathCount DESC

CREATE VIEW Continent_Total_death 
AS 
SELECT continent,  sum(cast(new_deaths as INT)) as TotalDeathCount
FROM Covid_Dataset..CovidDeaths
WHERE continent IS  not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

