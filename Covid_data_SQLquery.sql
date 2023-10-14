-- Data Exploration

SELECT * 
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
order by 3,4

SELECT * 
FROM ProjectPortfolio..CovidVaccinations
WHERE continent is NOT NULL
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
order by 1,2

-- Exploring Death Percentage

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
order by 1 ASC , 2 DESC

-- Exploring Death Percentage of USA

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location like '%states%'
and continent is NOT NULL
order by 2 DESC

-- Exploring Death Percentage of INDIA

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location like '%india%'
and continent is NOT NULL
order by 2 DESC

-- Exploring the percentage population that got infected with covid in INDIA

SELECT location, date, total_cases, population, 
(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS InfectionPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location like '%india%'
and continent is NOT NULL
order by 2 DESC

-- Explorring the countires with maximum infection rates in world 

SELECT location,population, MAX(total_cases) as Maxtotalcase , 
(CONVERT(float,MAX(total_cases))/NULLIF(CONVERT(float,population),0))*100 AS InfectionPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
order by 4 DESC

-- Exploring the highest death count in countries

SELECT location, MAX((CONVERT(int,total_deaths))) as Maxtotaldeath 
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
order by Maxtotaldeath DESC

-- Exploring the highest death count in CONTINENTS and other Groups

SELECT location, MAX((CONVERT(int,total_deaths))) as Maxtotaldeath 
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NULL
GROUP BY location
order by Maxtotaldeath DESC


-- Joining the vaccination data with covid data

SELECT * 
FROM ProjectPortfolio..CovidDeaths deaths
JOIN ProjectPortfolio..CovidVaccinations vac
ON deaths.location = vac.location
and deaths.date = vac.date


-- Exploring new vaccination vs total population to check the vaccination rate

SELECT deaths.location , deaths.continent, deaths.date, deaths.population, vac.new_vaccinations
FROM ProjectPortfolio..CovidDeaths deaths
JOIN ProjectPortfolio..CovidVaccinations vac
ON deaths.location = vac.location
and deaths.date = vac.date
WHERE deaths.continent is NOT null
order by 1,3 DESC


-- Exploring date wise vaccination from the start date of vaccination in a country

SELECT deaths.location , deaths.continent, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT (float, vac.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location,deaths.date) as Rollingcountvaccinaton
FROM ProjectPortfolio..CovidDeaths deaths
JOIN ProjectPortfolio..CovidVaccinations vac
ON deaths.location = vac.location
and deaths.date = vac.date
WHERE deaths.continent is NOT null
order by 1,3 DESC


-- Exploring the percentage population vaccinated according to the location using temp table 

DROP TABLE if exists #PopulationVaccinatedPercentage

CREATE TABLE #PopulationVaccinatedPercentage
(location nvarchar(255),
continent nvarchar(255),
date datetime, 
population float,
new_vaccinations float, 
Rollingcountvaccinaton float
)

INSERT INTO #PopulationVaccinatedPercentage
SELECT deaths.location , deaths.continent, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT (float, vac.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location,deaths.date) as Rollingcountvaccinaton
FROM ProjectPortfolio..CovidDeaths deaths
JOIN ProjectPortfolio..CovidVaccinations vac
ON deaths.location = vac.location
and deaths.date = vac.date
WHERE deaths.continent is NOT null
order by 1,3 DESC

SELECT * , (Rollingcountvaccinaton/population)*100 as VaccinationPercentage
FROM #PopulationVaccinatedPercentage


--Exploring important data points to create VIEWS for later references 

USE ProjectPortfolio
GO
CREATE VIEW PercentPopulationVaccinated as 
SELECT deaths.location , deaths.continent, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT (float, vac.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location,deaths.date) as Rollingcountvaccinaton
FROM ProjectPortfolio..CovidDeaths deaths
JOIN ProjectPortfolio..CovidVaccinations vac
ON deaths.location = vac.location
and deaths.date = vac.date
WHERE deaths.continent is NOT null


