# FluVaxView-Analysis
## About the project
Data cleaning and management of 2024-2025 U.S. CDC FluVaxView Data, plus a ggplot2 map of flu vax prevalence by December 2025
Data was queried from https://data.cdc.gov/Flu-Vaccinations/Influenza-Vaccination-Coverage-for-All-Ages-6-Mont/vh55-3he6/about_data
I am running this project out of a Box folder with files for *"data", "results", and "script"*. The packages you will need to load will be included at the top of the R script.
## Why this project matters
The COVID-19 pandemic has highlighted how disparities in infectious disease outcomes vary greatly by demographic characteristics such as age, pre-existing conditions, and race. Vaccination acts as a major protective factor against severe disease, but unfortunately is often distributed inequitably.
This project is the beginning of an independent ecological (state-level) exploratory analysis of how influenza vaccination overlaps with hospitalization rates by race, age, and pre-existing conditions on a state-level scale in the years following the COVID-19 pandemic.
I am in the process of using these data in a Tableau dashboard alongside sentinel site laboratory-confirmed hospitalization data from Flu-Surv-NET to determine whether there is a significant association between population characteristics and hospitalizations at the state level.
This data will be queried from https://gis.cdc.gov/GRASP/Fluview/FluHospRates.html
Month 12 (December) was selected as the month of interest for influenza vaccinations as this is just before the winter holiday season (peak transmission in the U.S.)