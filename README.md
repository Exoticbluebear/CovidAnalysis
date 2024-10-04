# COVID-19 Analysis with PostgreSQL

## Overview

This project analyzes COVID-19 data by examining cases, deaths, and vaccinations across various locations. Using PostgreSQL for data management, we derive insights about the pandemic's impact and vaccination efforts. The analysis includes key metrics such as total cases, death rates, and vaccination percentages, ultimately contributing to better understanding the pandemic dynamics.

## Table of Contents

- [Project Description](#project-description)
- [Technologies Used](#technologies-used)
- [Data Sources](#data-sources)
- [Setup Instructions](#setup-instructions)
- [Database Structure](#database-structure)
- [Queries Overview](#queries-overview)
- [Usage](#usage)

## Project Description

The COVID-19 Analysis project aims to provide insights into the progression of the virus and the effectiveness of vaccination efforts. Key functionalities include:

- Tracking total cases and deaths.
- Analyzing infection rates relative to population.
- Examining vaccination rates and their impact on population health.
- Visualizing data through various SQL queries.

## Technologies Used

- **PostgreSQL:** For data storage, management, and analysis.

## Data Sources

Data can be obtained from various reputable sources such as:

- [Johns Hopkins University COVID-19 Dataset](https://github.com/CSSEGISandData/COVID-19)
- [World Health Organization (WHO)](https://covid19.who.int/)

## Setup Instructions

### Prerequisites

- PostgreSQL installed on your local machine or access to a PostgreSQL server.

### Database Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/covid-analysis.git
   cd covid-analysis
   ```

2. **Create and populate tables:**
   Execute the following SQL commands in your PostgreSQL environment to create the necessary tables and load the data:
   ```sql
   CREATE TABLE coviddeaths (
       iso_code text,
       continent text,
       location text,
       date date,
       population float,
       total_cases float,
       new_cases float,
       new_cases_smoothed float,
       total_deaths float,
       new_deaths float,
       new_deaths_smoothed float,
       total_cases_per_million float,
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
   );

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
   );
   ```

3. **Insert data into the tables:** Populate the tables using the data sourced earlier.

## Queries Overview

The following SQL queries are used to extract meaningful insights from the data:

1. **Select all data:**
   ```sql
   SELECT * FROM coviddeaths;
   ```

2. **Total Cases vs Total Deaths:**
   ```sql
   SELECT location, date, population, total_cases, total_deaths,
       (total_deaths/total_cases) * 100 AS death_percentage
   FROM coviddeaths
   ORDER BY 1, 2;
   ```

3. **Countries with Highest Infection Rate:**
   ```sql
   SELECT location, population, MAX(total_cases) AS highest_infection_count,
       MAX(COALESCE((total_cases/population), 0)) * 100 AS percent_population_infected
   FROM coviddeaths
   GROUP BY location, population
   ORDER BY percent_population_infected DESC;
   ```

4. **Countries with Highest Death Count:**
   ```sql
   SELECT location, MAX(COALESCE(total_deaths, 0)) AS total_death_count
   FROM coviddeaths
   WHERE continent IS NULL
   GROUP BY location
   ORDER BY total_death_count DESC;
   ```

5. **Continents with Highest Death Count:**
   ```sql
   SELECT continent, MAX(COALESCE(total_deaths, 0)) AS total_death_count
   FROM coviddeaths
   WHERE continent IS NOT NULL
   GROUP BY continent
   ORDER BY total_death_count DESC;
   ```

6. **Global Numbers by Date:**
   ```sql
   SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
       SUM(new_deaths) / SUM(total_cases) * 100 AS death_percentage
   FROM coviddeaths
   GROUP BY date
   ORDER BY 1, 2;
   ```

7. **Total Numbers Globally:**
   ```sql
   SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
       SUM(new_deaths) / SUM(total_cases) * 100 AS death_percentage
   FROM coviddeaths;
   ```

8. **Join COVID Deaths and Vaccinations Tables:**
   ```sql
   SELECT *
   FROM coviddeaths dea
   JOIN covidvaccinations vac
       ON dea.location = vac.location AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
   ORDER BY 1, 2;
   ```

9. **Vaccination Percentage Calculation:**
   ```sql
   WITH popsVSvac AS (
       SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
           ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
       FROM coviddeaths dea
       JOIN covidvaccinations vac
           ON dea.location = vac.location AND dea.date = vac.date
       WHERE dea.continent IS NOT NULL
   )
   SELECT *, (rolling_people_vaccinated/population) * 100 AS vaccination_percentage
   FROM popsVSvac;
   ```

## Usage

- Connect to your PostgreSQL database.
- Execute the provided SQL commands to create tables and analyze the data.
- Modify the queries as needed to focus on specific regions, dates, or metrics.
