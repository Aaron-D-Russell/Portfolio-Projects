--Creating our first table and setting the datatypes for each column
CREATE TABLE IF NOT EXISTS covid_deaths(
iso_code VARCHAR(8),
continent CHAR(200),
location CHAR(250),
date DATE,
population NUMERIC,
total_cases NUMERIC,
new_cases NUMERIC,
new_cases_smoothed NUMERIC,
total_deaths NUMERIC,
new_deaths NUMERIC,
new_deaths_smoothed NUMERIC,
total_cases_per_million NUMERIC,
new_cases_per_million NUMERIC,
new_cases_smoothed_per_million NUMERIC,
total_deaths_per_million NUMERIC,
new_deaths_per_million NUMERIC,
new_deaths_smoothed_per_million NUMERIC,
reproduction_rate NUMERIC,
icu_patients NUMERIC,
icu_patients_per_million NUMERIC,
hosp_patients NUMERIC,
hosp_patients_per_million NUMERIC,
weekly_icu_admissions NUMERIC,
weekly_icu_admissions_per_million NUMERIC,
weekly_hosp_admissions NUMERIC,
weekly_hosp_admissions_per_million NUMERIC
);

--Creating our second table and setting the datatypes for each column
CREATE TABLE IF NOT EXISTS covid_vaccinations(
iso_code VARCHAR(8),
continent CHAR(200),
location CHAR(250),
date DATE,
new_tests NUMERIC,
total_tests BIGINT,
total_tests_per_thousand DOUBLE PRECISION,
new_tests_per_thousand DOUBLE PRECISION,
new_tests_smoothed INTEGER,
new_tests_smoothed_per_thousand DOUBLE PRECISION,
positive_rate DOUBLE PRECISION,
tests_per_case DOUBLE PRECISION,
tests_units CHAR(100),
total_vaccinations BIGINT,
people_vaccinated BIGINT,
people_fully_vaccinated BIGINT,
new_vaccinations BIGINT,
new_vaccinations_smoothed BIGINT,
total_vaccinations_per_hundred DOUBLE PRECISION,
people_vaccinated_per_hundred DOUBLE PRECISION,
people_fully_vaccinated_per_hundred DOUBLE PRECISION,
new_vaccinations_smoothed_per_million INTEGER,
stringency_index DOUBLE PRECISION,
population_density DOUBLE PRECISION,
median_age DOUBLE PRECISION,
aged_65_older DOUBLE PRECISION,
aged_70_older DOUBLE PRECISION,
gdp_per_capita DOUBLE PRECISION,
extreme_poverty DOUBLE PRECISION,
cardiovasc_death_rate DOUBLE PRECISION,
diabetes_prevalence DOUBLE PRECISION,
female_smokers DOUBLE PRECISION,
male_smokers DOUBLE PRECISION,
handwashing_facilities DOUBLE PRECISION,
hospital_beds_per_thousand DOUBLE PRECISION,
life_expectancy DOUBLE PRECISION,
human_development_index DOUBLE PRECISION
);

--Checking our imported data
SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--Checking our imported data
SELECT *
FROM covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

--Selecting data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Total Cases vs Total Deaths
--Shows the likelihood of dying if infected by Covid in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location LIKE '%States%' AND continent IS NOT NULL
ORDER BY 1,2;

--Total Cases vs Total Population
--Shows percentage of population that has been infected by Covid in United States
SELECT location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM covid_deaths
WHERE location LIKE '%States%' AND continent IS NOT NULL
ORDER BY 1,2;

--Viewing Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

--Viewing Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--LET'S BREAK THINGS DOWN BY CONTINENT
Select location, MAX(total_deaths) as TotalDeathCount
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Looking at Total Population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac;

--Creating Views to store data for future visualization

--Death Percentage View
CREATE VIEW Death_Percentage AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location LIKE '%States%' AND continent IS NOT NULL
--ORDER BY 1,2
;

--US Covid Infection Rate View
CREATE VIEW US_Covid_Infection_Rate AS
SELECT location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM covid_deaths
WHERE location LIKE '%States%' AND continent IS NOT NULL
--ORDER BY 1,2
;

--Percent of Population Infected View
CREATE VIEW Percent_Population_Infected AS
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
--ORDER BY PercentPopulationInfected DESC
;

--Total Death Count View
CREATE VIEW Total_Death_Count AS
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location
--ORDER BY TotalDeathCount DESC
;

--Global Covid Cases, Deaths, Death Percentage View
CREATE VIEW Global_Numbers AS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
--ORDER BY 1,2
;

--PopvsVac View
CREATE VIEW Pop_vs_Vac AS
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac;