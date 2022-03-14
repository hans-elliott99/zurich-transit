##                   ZURICH TRANSPORT PASSENGER DATA                           ##
##-----------------------------------------------------------------------------##
# Author: Hans Elliott
# About: This script compiles passenger data from the Zurich Transport Authority 
#        (Fahrzeugs der Verkehrsbetriebe Zürich, or VBZ). 
#        *Some of this script is adapted from scripts provided by the official
#        VBZ github (https://github.com/VerkehrsbetriebeZuerich). 
#        The link to the specific script is below:
#        https://github.com/VerkehrsbetriebeZuerich/ogd_examples_R/blob/main/05_Skripte/example_passengerdata.R
#
# Data:  All data files for this script come from: https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd (March 1, 2022).
#       The .CSV files that are loaded by the script below are the original names.
#
# Project: This script collects and prepares the ZBA passenger data to be combined
#          with ZBA trip data, creating a full dataset for a machine learning project.
#          The partner script is titled: 'punctuality.R'
# Full Machine Learning Project: https://www.kaggle.com/hanselliott/predicting-the-punctuality-of-zurich-transit
##-----------------------------------------------------------------------------##


#-------------#
#### Setup ####
#-------------#
# Libraries
library(pacman)
pacman::p_load(tidyverse, here, magrittr)

#------------------#
#### DATA MERGE ####
#------------------#
## First Load in Each Dataset
HALTESTELLEN <- read.csv(here("data","HALTESTELLEN.csv"),
                         encoding="UTF-8",
                         sep=";")

TAGTYP <- read.csv(here("data","TAGTYP.csv"),
                   encoding="UTF-8",
                   sep=";")

LINIE <- read.csv(here("data","LINIE.csv"),
                  encoding="UTF-8",
                  sep=";")

GEFAESSGROESSE <- read.csv(here("data","GEFAESSGROESSE.csv"),
                           encoding="UTF-8",
                           sep=";")

   
REISENDE <- read.csv(here("data","REISENDE.csv"),
                     encoding="UTF-8",
                     sep=";")

## Matching:
REISENDE_merge <- REISENDE %>%
  #remove column Linienname from REISENDE
  select(-Linienname)%>%
  #join HALTESTELLEN
  left_join(HALTESTELLEN,
            by=c("Haltestellen_Id"="Haltestellen_Id"))%>%
  #join TAGTYP
  left_join(TAGTYP,
            by=c("Tagtyp_Id"="Tagtyp_Id"))%>%
  #join LINIE
  left_join(LINIE,
            by=c("Linien_Id"="Linien_Id"))%>%
  #join GEFAESSGROESSE
  left_join(GEFAESSGROESSE,
            by=c("Plan_Fahrt_Id"="Plan_Fahrt_Id"))

#remove following DFs from memory, no longer needed
rm(REISENDE, TAGTYP, LINIE, GEFAESSGROESSE)

#---------------------------#
#### STOP NUM. CROSSWALK ####
#---------------------------#
## Need to create a crosswalk between 'Haltestellen_Id' (which is a stop ID that is inconsistent 
## across datasets), and 'Haltestellennummer', which is consistent across datasets,
## to then assign the proper 'Haltestellennummer' to each 'Nach_Hst_Id', which is the 
## dataset-inconsistent stop ID for the NEXT stop (aka, the after stop).
## This can be achieved using the HALTESTELLEN dataset loaded earlier 

HALTESTELLEN_id = HALTESTELLEN %>% select(Haltestellen_Id, Haltestellennummer) %>%
  rename(Nach_Hst_Id = Haltestellen_Id, #change stop ID (Haltestellen_Id) to next stop ID (Nach_Hst_Id)
         after_stopnum = Haltestellennummer #this is now the correct ID for the next stop
  )

# Add after_stopnum to full passenger data
#IMPORTANT: keep all.x since if current stop is the last stop, the next stop is NA
REISENDE_full = merge(REISENDE_merge, HALTESTELLEN_id, 
                      by = "Nach_Hst_Id", all.x = TRUE)


#---------------------------------------------------#
#### Passenger data by Stop (Haltestellennummer) ####
#---------------------------------------------------#
#### *Haltestellennummer = from_stopnum*
  ## Below, create DF that summarizes all of this information for each unique from_stop-after_stop combination
  ## Extrapolation factors for each variable are provided in the dataset. 
  ## They take the form: Tage_(...)
  ##  - per typical workday (DWV) / typical day (DTV) / typical saturday (Sa) and so on

passenger_merge = REISENDE_full %>%
  group_by(Linienname, Haltestellennummer, after_stopnum)%>%
  summarise(
    #avg. traffic per year 
    pax_per_yr=sum(Einsteiger*Tage_DTV, na.rm = TRUE), #sums all of the entries at each stop
    exit_per_yr=sum(Aussteiger*Tage_DTV, na.rm = TRUE), #sums all of the exits at each stop
    occ_per_yr=sum(Besetzung*Tage_DTV, na.rm = TRUE), #sums all of the mean occupants on each segment
    
    #avg. daily traffic across week Mo-So (DTV)
    pax_per_day=sum((Einsteiger*Tage_DTV)/365, na.rm = TRUE),
    exit_per_day=sum((Aussteiger*Tage_DTV)/365, na.rm = TRUE), 
    occ_per_day=sum((Besetzung*Tage_DTV)/365, na.rm = TRUE),
    
    #avg. traffic per workday Mo-Fr (DWV)
    pax_per_workday=sum((Einsteiger*Tage_DWV)/251, na.rm = TRUE),
    exit_per_workday=sum((Aussteiger*Tage_DWV)/251, na.rm = TRUE), 
    occ_per_workday=sum((Besetzung*Tage_DWV)/251, na.rm = TRUE),
    
    #avg. traffic per Saturday (Sa)
    pax_per_sa=sum((Einsteiger*Tage_SA)/52, na.rm = TRUE),
    exit_per_sa=sum((Aussteiger*Tage_SA)/52, na.rm = TRUE), 
    occ_per_sa=sum((Besetzung*Tage_SA)/52, na.rm = TRUE),
    
    #avg. traffic per Sunday (So)
    pax_per_so=sum((Einsteiger*Tage_SO)/62, na.rm = TRUE),
    exit_per_so=sum((Aussteiger*Tage_SO)/62, na.rm = TRUE), 
    occ_per_so=sum((Besetzung*Tage_SO)/62, na.rm = TRUE),
    
    #avg. traffic per Night Friday to Saturday (Sa_N)
    pax_per_sa_n=sum((Einsteiger*Tage_SA_N)/52, na.rm = TRUE),
    exit_per_sa_n=sum((Aussteiger*Tage_SA_N)/52, na.rm = TRUE), 
    occ_per_sa_n=sum((Besetzung*Tage_SA_N)/52, na.rm = TRUE),
    
    #avg. traffic per Night Saturday to Sunday (So_N)
    pax_per_so_n=sum((Einsteiger*Tage_SO_N)/52, na.rm = TRUE),
    exit_per_so_n=sum((Aussteiger*Tage_SO_N)/52, na.rm = TRUE), 
    occ_per_so_n=sum((Besetzung*Tage_SO_N)/52, na.rm = TRUE),
    
    #other
    distance=mean(Distanz),
    measurements = sum(Anzahl_Messungen), #Number of measurements (which they use to measure passenger data)
    seats = mean(SITZPLAETZE),           #Number of seats on transit
    cap_4m2 = mean(KAP_4m2)              #Capacity based on the occupancy of all seats and one person per m2 of standing space
  ) %>% unique()
   
# rename variables for consistency across project files
passenger_merge %<>% rename(
  from_stopnum = Haltestellennummer,        # matches to 'from_stopnum' in punctuality.csv
  line = Linienname                         #matches to 'line' in punctuality.csv
)

# Notes:
  # The data provided here are calculated mean values for individual journeys on the timetable, 
  # not permanently measured values from all vehicles, according to source (https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd)


#----------------------------#
#### FINAL PASSENGER DATA ####
#----------------------------#
  #write dataset to desired folder ["data"] and provide name ["passenger.csv"]
  #user may have to add additional/different folder titles based on their file structure
  #
write.csv(passenger_merge, here("data","passenger.csv"), row.names = FALSE)
  #
  #This data will match to punctuality data based on 'line' and 
  #            stops ('from_stopnum','after_stopnum')




#### Some key terms ####
#einsteiger = entries (Mean value of people boarding at the bus stop from the measurements taken into account)
#aussteiger = exits (Mean value of people getting off at the bus stop from the measurements taken into account)
#besetzung = mean occupancy during the section between Stop & After Stop (Haltestellen_ID,Nach_Hst_Id)
#fahrdistanz = driving distance between Stop & After Stop (meters)



