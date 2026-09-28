# ILE Data Project- HPV among LGBTQ populations ---------------------------
# Importing Packages ------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(
  #R helper packages
  installr, conflicted,sessioninfo,
  #Import/export functions
  here, rio,haven,
  #Data Management
  tidyverse, forcats, janitor, summarytools,stringr,
  #Data analysis packages
  lsr, survey, srvyr, marginaleffects, lsr, parameters, modelbased, margins, parameters,
  #Making tables
  summarytools, gtsummary, rmarkdown, gt, gtExtras, knitr, flextable,
  #Geo-spatial mapping and graphical tools
  ggplot2, maps, usmap,
  #Color Palettes for mapping/ visualization
  RColorBrewer,viridis,
  #Helper packages for data viz
  glue, htmltools)
#Got to load summarytools separately because it doesn't like to behave
#Frequency tables
library(summarytools)

conflict_prefer_all("scales",    quiet=T) 
conflict_prefer_all("lubridate", quiet=T)  
conflict_prefer_all("dplyr",     quiet=T)   
conflict_prefer("filter",         "dplyr")          
conflict_prefer("export",         "rio")   

# Importing file ----------------------------------------------------------
#Downloaded data from FluVaxView Website
#https://data.cdc.gov/Flu-Vaccinations/Influenza-Vaccination-Coverage-for-All-Ages-6-Mont/vh55-3he6/about_data
fluvaxview <- import(here("data","fluvaxview.csv")) %>% janitor::clean_names()
fluvaxsimple <-fluvaxview %>%
  filter(
    grepl("2019|^202",season_survey_year),
    fips <= 56,
    month == 12)
names(fluvaxsimple)
fluvaxsimple <-fluvaxsimple %>%
  select(c("geography", "fips", "season_survey_year", "month", "dimension_type", "dimension", "estimate_percent"))
fluvaxrace <- fluvaxsimple %>%
  filter( dimension_type == "Race and Ethnicity")
freq(fluvaxrace$dimension)
freq(fluvaxsimple$season_survey_year)
class(fluvaxrace$estimate_percent)
fluvaxrace <- fluvaxrace %>%
  mutate(
    race = case_when(
      grepl("Black", dimension) ~ "Black",
      grepl("White", dimension) ~ "White",
      grepl("Other", dimension) ~ "Other",
      TRUE ~ "Hispanic"),
    dimension_type = "race",
    vax_percent= if_else(estimate_percent == "NR †", NA_real_, as.numeric(estimate_percent))) %>%
  select(c("geography", "fips", "season_survey_year", "dimension_type", "race", "vax_percent"))
fluvaxage <- fluvaxsimple %>%
  filter( dimension_type == "Age")
fluvaxagerisk <- fluvaxage %>%
  filter(grepl("High Risk$", dimension))
fluvaxageonly <- fluvaxage %>%
  filter(!grepl("High", dimension))
freq(fluvaxageonly$dimension)
fluvaxagerisk <- fluvaxagerisk %>%
  mutate( riskgroup = case_when(
    grepl("not", dimension) ~ "Elevated",
    TRUE ~ "Normal"),
    age = case_when(
      grepl("6 Months - ", dimension) ~ "<18",
      grepl("5-12", dimension) ~ "<18",
      grepl("13-17", dimension) ~ "<18",
      grepl("18-49", dimension) ~ "18-49",
      grepl("50-64", dimension) ~ "50-64",
      grepl("18-64", dimension) ~ "18-64",
      grepl(">=6 Months", dimension)|grepl("6 Months flu", dimension) ~ "Over 6 months",
      grepl("18 Years", dimension)|grepl("18 Years flu", dimension) ~ "Adults 18 or older",
      grepl("18-64",dimension) ~ "Adults under 65",
      grepl("Greater 65", dimension)|grepl(">=65",dimension) ~ "65+",
      TRUE ~ NA_character_),
    vax_percent= if_else(estimate_percent == "NR †", NA_real_, as.numeric(estimate_percent))) %>%
  select(c("geography", "fips", "season_survey_year", "dimension_type", "age", "riskgroup","vax_percent"))
fluvaxageonly <- fluvaxageonly %>%
  mutate( age = case_when(
    grepl("6 Months - ", dimension) ~ "<18",
    grepl("5-12", dimension) ~ "<18",
    grepl("13-17", dimension) ~ "<18",
    grepl("18-49", dimension) ~ "18-49",
    grepl("50-64", dimension) ~ "50-64",
    grepl("Greater 65", dimension)|grepl(">=65",dimension) ~ "65+",
    grepl(">=6 Months", dimension)|grepl("6 Months flu", dimension) ~ "Over 6 months",
    grepl("18 Years", dimension)|grepl("18 Years flu", dimension) ~ "Adults 18 or older",
    grepl("18-64",dimension) ~ "Adults under 65",
    TRUE ~ NA_character_),
    broadagecat = case_when(
      grepl(">=6 Months", dimension)|grepl("6 Months flu", dimension) ~ "Over 6 months",
      grepl("18 Years", dimension)|grepl("18 Years flu", dimension) ~ "Adults 18 or older",
      grepl("18-64",dimension) ~ "Adults under 65",
      TRUE ~ NA_character_),
    vax_percent= if_else(estimate_percent == "NR †", NA_real_, as.numeric(estimate_percent))) %>%
  select(c("geography", "fips", "season_survey_year", "dimension_type", "age", "vax_percent"))
adultsonly <-fluvaxageonly %>%
  filter(age == "Adults 18 or older",
         season_survey_year == "2024-25")
# Visualization -----------------------------------------------------------
# Making labels for vaccine rates
p_load(usmapdata)
centroids <- usmapdata::centroid_labels("states")
centroids <- centroids %>%
  mutate(
    fips = sub("^0","",fips))
data_labels_only <- merge(centroids, adultsonly, by= "fips")
plot_usmap(regions= "states", data = adultsonly, values= "vax_percent", color="white",labels= FALSE) +
  theme_void()+
  theme(
    plot.background = element_rect(fill="transparent",color= NA),
    panel.background = element_rect(fill="transparent", color=NA),
    panel.grid = element_blank(),
    legend.background = element_rect(fill="transparent", color=NA),
    legend.box.background = element_rect(fill="transparent", color= NA) )+
  theme(plot.title = element_text(face = "bold"))+
  labs(title ="2024-25 Seasonal U.S Adult Vaccination by State",
        subtitle = "Vaccinated before peak influenza transmission (Dec. 2024)",
    fill= "% Vaccinated")+
  theme(legend.position = "top")+
  geom_sf_label(
    data = data_labels_only,
    aes(label = scales::number(vax_percent, accuracy = 0.1)),
    fill= "lightskyblue",
    alpha= 0.1,
    color = "black",
    linewidth = 0,
    size = 3,
    label.padding= unit(0,"lines"))+
  scale_fill_viridis(option = "mako", na.value = "gray", direction = -1)
# ggsave("fluvaxfreqadult2425.png", bg="transparent",width=6, height= 4, units= "in", dpi = 300)

# Exporting so I can build my Tableau dashboard ---------------------------
export(fluvaxageonly, "fluvaxage.xlsx" )
export(fluvaxagerisk, "fluvaxriskbyage.xlsx")
export(fluvaxrace, "fluvaxrace.xlsx")

# R studio Version  -------------------------------------------------------
session_info()

