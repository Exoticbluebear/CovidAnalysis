CREATE TABLE coviddeaths (
    iso_code text,	
	continent text,
	location text,
	date date,
	population float,
	total_cases	float,
	new_cases float,
	new_cases_smoothed float,
	total_deaths float,
	new_deaths float,
	new_deaths_smoothed float,
	total_cases_per_million	float,
	new_cases_per_million float,
	new_cases_smoothed_per_million float,
	total_deaths_per_million float,
	new_deaths_per_million float,
	new_deaths_smoothed_per_million float,
	reproduction_rate float,	
	icu_patients float,
	icu_patients_per_million float,
	hosp_patients float,
	hosp_patients_per_million float,
	weekly_icu_admissions float,
	weekly_icu_admissions_per_million float,
	weekly_hosp_admissions float,
	weekly_hosp_admissions_per_million float 
) 

select * from coviddeaths;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1, 2

-- looking at Total Cases vs Total Deaths
-- shows what percentage of population got covid

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
-- where location = 'Canada'
order by 1, 2

-- looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as highest_infection_count, max(COALESCE((total_cases/population),0))*100 as 
	percent_population_infected
from coviddeaths
-- where location = 'Canada'
group by location, population
order by percent_population_infected desc

-- Showing Countires with Highest Death Count

select location, max(COALESCE(total_deaths, 0)) as total_death_count
from coviddeaths
where continent is null
-- where location = 'Canada'
group by location
order by total_death_count desc

-- Showing continents with Highest Death Count

select continent, max(COALESCE(total_deaths, 0)) as total_death_count
from coviddeaths
where continent is not null
-- where location = 'Canada'
group by continent
order by total_death_count desc

-- Global numbers by date

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
	sum(new_deaths)/sum(total_cases)*100 as death_percentage
from coviddeaths
-- where location = 'Canada'
group by date
order by 1, 2

-- Total numbers globaly

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
	sum(new_deaths)/sum(total_cases)*100 as death_percentage
from coviddeaths
-- where location = 'Canada'
-- group by date
order by 1, 2

CREATE TABLE covidvaccinations (
	iso_code text,
	continent text,
	location text,
	date date,
	new_tests float,
	total_tests float,
	total_tests_per_thousand float,
	new_tests_per_thousand float,
	new_tests_smoothed float,
	new_tests_smoothed_per_thousand float,
	positive_rate float,
	tests_per_case float,
	tests_units text,
	total_vaccinations float,
	people_vaccinated float,
	people_fully_vaccinated float,
	new_vaccinations float,
	new_vaccinations_smoothed float,
	total_vaccinations_per_hundred float,
	people_vaccinated_per_hundred float,
	people_fully_vaccinated_per_hundred float,
	new_vaccinations_smoothed_per_million float,
	stringency_index float,
	population_density float,
	median_age float,
	aged_65_older float,
	aged_70_older float,
	gdp_per_capita float,
	extreme_poverty float,
	cardiovasc_death_rate float,
	diabetes_prevalence float,
	female_smokers float,
	male_smokers float,
	handwashing_facilities float,
	hospital_beds_per_thousand float,
	life_expectancy float,
	human_development_index float
)

-- joining coviddeaths and covidvaccinations tabel
select *
 from coviddeaths dea join covidvaccinations vac
   on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- looking at total population vs vaccinations 
-- using CTE

with popsVSvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location
	order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

select * , (rolling_people_vaccinated/population)*100 from popsVSvac


--TEMP TABLE


drop table if exists percent_population_vaccinated	;
create table percent_population_vaccinated
(continent text, location text, date date, population float, new_vaccination float, 
	rolling_people_vaccinated float);

insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location
	order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date ;
--where dea.continent is not null
--order by 2,3 

select * , (rolling_people_vaccinated/population)*100 from percent_population_vaccinated

-- creating a view for percent population vaccinated

create view percent_population_vaccinated as	
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location
	order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 

