#!/usr/bin/bash

mkdir -p data
cd data

# As of April, 2023:
# To see all available weeks of ride data for 2022, visit:
#       https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd_2022
# and to see all available years, visit:
#       https://data.stadt-zuerich.ch/dataset?q=%22SOLL-IST-Vergleich%22&sort=title_string+desc
# (that includes haltestelle and haltepunkt)
# For all other tables, visit:
#       https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd

# RIDE DATA
# 2 consecutive weeks of ride data from 2022 (fahrzeiten):
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd_2022/download/Fahrzeiten_SOLL_IST_20220102_20220108.csv

wget https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd_2022/download/Fahrzeiten_SOLL_IST_20220109_20220115.csv

# haltestelle (for 2022)
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd_2022/download/Haltestelle.csv

# haltepunkt (for 2022)
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd_2022/download/Haltepunkt.csv

# OTHER TABLES
# linie (line)
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd/download/LINIE.csv

# reisende (passengers)
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd/download/REISENDE.csv

# haltestellen (more stop info)
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd/download/HALTESTELLEN.csv

# tagtyp
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd/download/TAGTYP.csv

# gefaessgrosse ("vessel" info)
wget https://data.stadt-zuerich.ch/dataset/vbz_fahrgastzahlen_ogd/download/GEFAESSGROESSE.csv
