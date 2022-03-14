##                 ZURICH TRANSPORT - FULL MERGED DATA                         ##
##-----------------------------------------------------------------------------##
# Author: Hans Elliott
# About: This script compiles passenger data from the Zurich Transport Authority 
#        (Fahrzeugs der Verkehrsbetriebe Zürich, or VBZ). 
#        *Some of this script is adapted from scripts provided by the official
#        VBZ github (https://github.com/VerkehrsbetriebeZuerich). 
#        The link to the specific script is below:
#        https://github.com/VerkehrsbetriebeZuerich/ogd_examples_R/blob/main/05_Skripte/example_passengerdata.R
# Data: The data files used in the script are created by the partner scripts described below.
# Project: This script merges the ZBA passenger and punctuality data, creating a 
#          full dataset for a machine learning project.
#          The partner scripts are titled: 'punctuality.R' & 'passenger.R', which will process
#          and output the data needed for this merge file
# Full Machine Learning Project: https://www.kaggle.com/hanselliott/predicting-the-punctuality-of-zurich-transit
##-----------------------------------------------------------------------------##

#-----------------------------#
#### Load Libraries & Data ####
#-----------------------------#
#Libraries:
library(pacman)
pacman::p_load(tidyverse, here, translateR, magrittr, data.table)

# Data:
  #files produced by partner scripts identified above
passenger_df = here("data","passenger.csv") %>% fread()
punctuality_df = here("data","punctuality.csv") %>% fread()

#-------------#
#### Merge ####
#-------------#
merged = merge(punctuality_df, passenger_df,
               by = c("line", "from_stopnum", "after_stopnum"), 
               all.x = TRUE)


#--------------#
#### EXPORT ####
#--------------#
# Full Dataset:
#write.csv(merged, here("data", "zurich_transit_allvars.csv"), row.names = FALSE)

#Selected Variables for ML Project:
df = merged %>% select(
  # identifiers
  line, vehicle_id, course_id, transit_type, circulation_num,
  #route information
  route_id, route_desig, route_type, #vast majority of route_type==1 (out of 1,2,3,4), so might not be useful 
  
  # stop information (from - after)
  from_stopnum, from_stopshort, from_stopfull, 
  after_stopnum, after_stopshort, after_stopfull,
  from_breakpoint, after_breakpoint,
  # date information
  operating_date, from_date, after_date,
  # sequence information (where in the sequence of a lines stops)
  direction, from_stop_seq, after_stop_seq,
  
  # average passenger counts for line traveling between the 'from' and 'after' stop
  # (also can be thought of as average number of people boarding at 'from' stop headed to 'after' stop)
  pax_per_yr, pax_per_day, pax_per_workday, pax_per_sa, pax_per_so,
  # average exit counts for line traveling between the 'from' and 'after' stop
  exit_per_yr, exit_per_day, exit_per_workday, exit_per_sa, exit_per_so,
  # average occupancy (# of people on board transit) for line traveling from-after
  occ_per_yr, occ_per_day, occ_per_workday, occ_per_sa, occ_per_so,
  
  # average line information for line traveling from-after
  distance, seats, cap_4m2, measurements,
  
  #'from' stop - time data
  from_sch_arr, from_act_arr,
  from_sch_dep, from_act_dep,
  
  #'after' stop - time data
  after_sch_arr, after_act_arr,
  after_sch_dep, after_act_dep,
  
  #geospatial data for each stop
  from_latitude, from_longitude,
  after_latitude, after_longitude
  )

# add unit_id variable as a unique identifier for each trip
unit_id = c(1:nrow(df))
df = cbind(unit_id, df)

# EXPORT
write.csv(df, here("data", "zurich-transit.csv"), row.names = FALSE)




# other ----------
skimr::skim(df)


## Map Df:
bus = c("BG","BL","BP","BZ")
mapping_df = 
  df %>% select(line, from_stopnum, from_longitude, from_latitude, transit_type) %>% unique() %>%
  mutate(transit_type = ifelse(transit_type %in% bus, "B", transit_type) )

write.csv(mapping_df, here("data", "zurich_map_data.csv"), row.names = FALSE)


#
df %>% select(after_sch_dep,after_act_dep) %>%
  ggplot() + 
    geom_point(aes(x=after_sch_dep, y = after_act_dep))


# Notes for Hans:
# No night transit in this week sample, so any vars related to night transit are dropped in select df
# line 2 is most common, it is type T (with some NAs, but most likely due to the transit_type
# coming from the passenger data and not matching to every ride, so could be imputed)
# believe corresponds to the S2
# https://en.wikipedia.org/wiki/S2_(ZVV)

