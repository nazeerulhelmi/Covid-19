----// selecting all data from coviddeaths //--
--SELECT * 
----FROM CovidP.dbo.CovidDeaths
--FROM CovidP..CovidDeaths
--WHERE continent IS NOT NULL
 
----// select data from covidvacc //--
--SELECT * --selecting all data
----FROM CovidP.dbo.CovidVacc
--FROM CovidP..CovidVacc
--WHERE continent IS NOT NULL

----// select location
SELECT location, date, new_cases, total_cases, total_deaths, population
FROM CovidP..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

SELECT location, date, total_cases, cast(total_deaths AS int) AS total_deaths, (cast(total_deaths AS int)/total_cases)*100 as death_per_case
FROM CovidP..CovidDeaths
--WHERE continent IS NOT NULL
WHERE location = 'Malaysia'
ORDER BY 1,2

SELECT location, population, MAX(total_cases) AS highest_case_count, MAX(total_cases/population*100) AS max_infected_percentage
FROM CovidP..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

SELECT location, MAX(cast(total_deaths AS int)) as max_total_deaths
FROM CovidP..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

SELECT continent, MAX(cast(total_deaths AS int)) as max_total_deaths
FROM CovidP..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT SUM(new_cases) AS case_count, SUM(cast(new_deaths AS int)) AS death_count, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_per_case
FROM CovidP..CovidDeaths
WHERE continent IS NOT NULL

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM CovidP..CovidDeaths AS d
INNER JOIN CovidP..CovidVacc AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

WITH PopVsVacc (continent, location, date, population, new_vaccinations, rolling_vaccinated) AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM CovidP..CovidDeaths AS d
INNER JOIN CovidP..CovidVacc AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, rolling_vaccinated/population*100 AS PercentPopulationVaccinated
FROM PopVsVacc

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM CovidP..CovidDeaths AS d
INNER JOIN CovidP..CovidVacc AS v
ON d.location = v.location
AND d.date = v.date

SELECT *, (rolling_vaccinated/population)*100
FROM #PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM CovidP..CovidDeaths AS d
INNER JOIN CovidP..CovidVacc AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated