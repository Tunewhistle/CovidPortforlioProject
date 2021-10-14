--select *
--from PortforlioProject.dbo.covidvaccinations;

--select count(*)
--from PortforlioProject.dbo.covidvaccinations;

--select *
--from PortforlioProject.dbo.coviddeaths;
--order by 3,4;

--Select data that I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortforlioProject.dbo.coviddeaths
order by 1,2;


--Looking at Total cases vs Total deaths
--Shows the likelihood of dying like in a country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortforlioProject.dbo.coviddeaths
where Location like '%States%'
order by 1,2;

--Looking at Total cases vs Population
Select Location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as PercentageInfectedPopulation
from PortforlioProject.dbo.coviddeaths
where Location like '%States%'
order by 1,2;


--Looking at the highest infection rate compared to population
Select location, population, max(cast(total_cases as float)) as HighestInfectionCount, max(cast(total_cases as float)/cast(population as float))*100 as HighestPercentageofPopulationInfected
From PortforlioProject.dbo.coviddeaths
Group by location, population
order by HighestPercentageofPopulationInfected DESC;


--Showing countries with highest death count
Select location, Max(cast(total_deaths as float)) as TotalDeathCount
From PortforlioProject.dbo.coviddeaths
where Continent is not null
group by location
order by TotalDeathCount desc;

--Shows continents with the highest death count per population
Select continent, max(cast (total_deaths as float)) as HighestTotalDeathCount
from PortforlioProject.dbo.coviddeaths
where Continent is not null
group by continent
order by HighestTotalDeathCount desc;

--Looking at daily new deaths vs new cases rate globally
Select date, sum(cast(new_cases as float)) as DailyNewCases, sum(cast(new_deaths as float)) as DailyNewDeaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DailyDeathPercentagePerCases
From PortforlioProject.dbo.CovidDeaths
Where continent is not null
group by date
order by date;


--Looking at total population vs vaccination
--Use CTE
With PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortforlioProject.dbo.CovidDeaths as dea
inner join PortforlioProject.dbo.CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;
)
Select *, (RollingPeopleVaccinated/cast(Population as float))*100 as VaccinationsVsPopulation
from PopVsVac


--TEMP Table
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortforlioProject.dbo.CovidDeaths as dea
inner join PortforlioProject.dbo.CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

Select *, (RollingPeopleVaccinated/cast(Population as float))*100 as VaccinationsVsPopulation
from #PercentagePopulationVaccinated;


--Create View to store date for visualizations later
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortforlioProject.dbo.CovidDeaths as dea
inner join PortforlioProject.dbo.CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;