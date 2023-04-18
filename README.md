# zurich-transit
These scripts downloand and compile public transit data from the city of Zurich's open data portal.  
In the compiled datasets, each dataset (`data/zurich_transit_<WeekStartDate>.csv`) contains data for one week (7 days, starting at WeekStartDate).  
Each row is a single trip between two stops, and the features describe the trip's position in the transit network, the scheduled and actual ride times, and some characteristics of that particular segment of the network.  

Detailed variable descriptions are available on Kaggle: https://www.kaggle.com/hanselliott/a-week-of-zurich-transit  


To compile the datasets, first clone this repo:  
- `git clone https://github.com/hans-elliott99/zurich-transit.git && cd zurich-transit`

Then, run:  
- `$ bash ./get_data.sh`  
which will create a 'data/' directory and download needed datasets (see below for info on how to modify this script to download different weeks of data).  
- `$ bash ./compile_data.sh`  
which will install any needed R packages and then compile a merged dataset for each week of 'Fahrzeiten' data in the data directory.  

## Required Data
Assuming that Stadt Zurich Open Data does not change their api, you can run `get_data.sh` to download all the needed datasets.   
Links can be modified to access different weeks of data.   

### Ride Time Data
The 'Fahrzeiten' datasets contain the arrival and departure times for the whole transit network for a specific week.  
For example, Fahrzeiten_SOLL_IST_20220102_20220108.csv contains the data for the week of Jan 2, 2022 through Jan 8, 2022.  
`get_data.sh` will download this week and the following week, but this can easily be modified by changing the links to whichever weeks are needed. Final datasets will automatically be created for any week of 'Fahrzeiten' data that appears in the `data/` directory.  

As of April 2023, the 2022 data can be found at this link: https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd_2022  
The latest data can be found here: https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd  
Previous years are also available.  

### Supporting Datasets
**PUNCTUALITY DATA**  
As of April, 2023, `get_data.sh` downloads the following datasets from: https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd_2022
- Haltepunkt.csv
- Haltestelle.csv

**PASSENGER DATA**  
As of April, 2023, `get_data.sh` downloads the following datasets from: https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd
- REISENDE.csv  
- HALTESTELLEN.csv  
- TAGTYP.csv  
- GEFAESSGROESSE.csv  
- LINIE.csv  
