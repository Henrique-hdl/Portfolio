	-- 28 de janeiro de 2020
	-- 30 de abril de 2021
	
	SELECT *
	FROM PortfolioProject..CovidDeaths
	order by 3,4

	--SELECT *
	--FROM PortfolioProject..CovidDeaths
	--order by 3,4

	--Selecionar os dados que serão utilizados

SELECT Location, date, total_cases, new_cases, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Analisando Total de Casos x Total de Mortes
-- Chance de morte caso contraia COVID-19
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Brazil'
ORDER BY 1,2	

-- Analisando Total de Casos x População
-- Mostra a porcentagem da população que contraiu COVID - 19
SELECT Location, date, total_cases, Population, (total_deaths/Population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
ORDER BY 1,2

-- Quais países tem as maiores taxas de infecção

SELECT Location , Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc


-- Países com a maior número de mortes

SELECT Location , MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Continentes com os maiores números de mortes

SELECT continent , MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(population) as population
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent is not null
GROUP BY Continent
ORDER BY TotalDeathCount desc

-- Números globais

SELECT SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent is not null
ORDER BY 1,2

-- Analisando população total x vacinação

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	 On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	 On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Tabela Temp
-- DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	 On dea.location = vac.location
	 and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Visualização de dados

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	 On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3