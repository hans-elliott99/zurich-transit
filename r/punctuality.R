##                   ZURICH TRANSPORT PUNCTUALITY DATA                         ##
##-----------------------------------------------------------------------------##
# Author: Hans Elliott
# About: This script compiles transit trip data from the Zurich Transport Authority 
#        (Fahrzeugs der Verkehrsbetriebe Zürich, or VBZ). 
#        *Much of this script is adapted from a script provided by the official
#        VBZ github (https://github.com/VerkehrsbetriebeZuerich). 
#        The link to the specific script is below:
#        https://github.com/VerkehrsbetriebeZuerich/ogd_examples_R/blob/main/05_Skripte/example_traveltimedata.R
#
# Data: All data files for this script come from: https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd (March 1, 2022).
#       The .CSV files that are loaded by the script below are the original names.
#
# Project: This script collects and prepares the ZBA trip data to be combined
#          with ZBA passenger data, to create a full dataset for a machine learning project.
#          The partner scripts are titled: 'passenger.R' and 'full_merge.R'
# Full Machine Learning Project: https://www.kaggle.com/hanselliott/predicting-the-punctuality-of-zurich-transit

#-------------#
#### Setup ####
#-------------#
# Libraries
library(pacman)
pacman::p_load(tidyverse, here, magrittr)

#---------------------#
#### Matching Data ####
#---------------------#
# Load merge Data
haltepunkt = here("data", "haltepunkt.csv") %>% read_csv()
haltestelle = here("data", "haltestelle.csv") %>% read_csv()

#Merge with 'fahrzeiten' data:
#
punctuality_df = here("data", "Fahrzeiten_SOLL_IST_20220102_20220108.csv") %>% read_csv() %>%
  #join haltepunkt to "from" ("von")
  left_join(haltepunkt,
            by=c("halt_punkt_id_von"="halt_punkt_id",
                 "halt_punkt_diva_von"="halt_punkt_diva",
                 "halt_id_von"="halt_id")) %>%
  #rename new columns with suffix "von"
  rename(GPS_Latitude_von=GPS_Latitude,
         GPS_Longitude_von=GPS_Longitude,
         GPS_Bearing_von=GPS_Bearing,
         halt_punkt_ist_aktiv_von=halt_punkt_ist_aktiv) %>%
  #join haltepunkt to "after" ("nach")
  left_join(haltepunkt,
            by=c("halt_punkt_id_nach"="halt_punkt_id",
                 "halt_punkt_diva_nach"="halt_punkt_diva",
                 "halt_id_nach"="halt_id")) %>%
  #rename new columns it with suffix "nach"
  rename(GPS_Latitude_nach=GPS_Latitude,
         GPS_Longitude_nach=GPS_Longitude,
         GPS_Bearing_nach=GPS_Bearing,
         halt_punkt_ist_aktiv_nach=halt_punkt_ist_aktiv)%>%
  #join haltestelle to "from" ("von")
  left_join(haltestelle,
            by=c("halt_id_von"="halt_id",
                 "halt_diva_von"="halt_diva",
                 "halt_kurz_von1"="halt_kurz"))%>%
  #rename new columns with suffix "von"
  rename(halt_lang_von=halt_lang,
         halt_ist_aktiv_von=halt_ist_aktiv)%>%
  #join haltestelle to "after" ("nach")
  left_join(haltestelle,
            by=c("halt_id_nach"="halt_id",
                 "halt_diva_nach"="halt_diva",
                 "halt_kurz_nach1"="halt_kurz"))%>%
  #rename new columns with suffix "nach"
  rename(halt_lang_nach=halt_lang,
         halt_ist_aktiv_nach=halt_ist_aktiv)

#------------------------#
#### ADD TRANSIT TYPE ####
#------------------------#
#load line description data:
LINIE <- read.csv(here("data","LINIE.csv"),
                  encoding="UTF-8",
                  sep=";")
# select wanted variables
transit_type = LINIE %>% transmute(
  linie = Linienname,
  transit_type = VSYS
)
# add transit type to each line
punctuality_df = merge(transit_type, punctuality_df, by = "linie")


#---------------------------------------#
#### Translate Col Names  to English ####
#---------------------------------------#
punctuality_df %<>% rename(
  # line information
  line  =  linie,  direction = richtung, operating_date = betriebsdatum, 
  vehicle_id = fahrzeug, course_id = kurs,
  #arrivals, departures from
  from_stop_seq = seq_von, from_stopnum = halt_diva_von, from_breakpoint = halt_punkt_diva_von, 
  from_stopshort = halt_kurz_von1, from_date = datum_von, 
  from_sch_arr = soll_an_von,  from_act_arr = ist_an_von, #scheduled and actual arrivals,
  from_sch_dep = soll_ab_von, from_act_dep = ist_ab_von,   # departures at 'from' stop
  #arrivals, departures to
  after_stop_seq = seq_nach, after_stopnum = halt_diva_nach, after_breakpoint = halt_punkt_diva_nach, 
  after_stopshort = halt_kurz_nach1, after_date = datum_nach, 
  after_sch_arr = soll_an_nach, after_act_arr = ist_an_nach1, #scheduled and actual arrivals,
  after_sch_dep = soll_ab_nach, after_act_dep = ist_ab_nach,  # departures at 'after' stop
  #identifying variables
  journey_id = fahrt_id, route_id = fahrweg_id, 
  route_num = fw_no, route_type = fw_typ, route_code = fw_kurz, 
  route_desig = fw_lang, circulation_num = umlauf_von, 
  #foreign keys - were necessary for initial matching in creation of this dataset
  from_stop_id = halt_id_von, after_stop_id = halt_id_nach, 
  from_brkpnt_id = halt_punkt_id_von, after_brkpnt_id = halt_punkt_id_nach, 
  #other variables
  #latitude,  longitude, gps compass bearing
  from_latitude = GPS_Latitude_von, from_longitude = GPS_Longitude_von, from_gps_bearing = GPS_Bearing_von, 
  after_latitude = GPS_Latitude_nach, after_longitude = GPS_Longitude_nach, after_gps_bearing = GPS_Bearing_nach, 
  #breakpoint status (active == T,inactive == F) for 'from' and 'after' stations
  from_brkpnt_active = halt_punkt_ist_aktiv_von, 
  after_brkpnt_active = halt_punkt_ist_aktiv_nach, 
  #full stop name and stop status (active == T, inactive == F)
  from_stopfull = halt_lang_von, from_stop_active = halt_ist_aktiv_von, 
  after_stopfull = halt_lang_nach, after_stop_active = halt_ist_aktiv_nach
)


#---------------------#
#### FINAL DATASET ####
#---------------------#
#write dataset to desired folder ["data"] and provide name ["punctuality.csv"]
#user may have to add additional/different folder titles based on their file structure
write.csv(punctuality_df, here("data", "punctuality.csv"), row.names = FALSE)
