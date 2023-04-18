#!/usr/bin/bash

Rscript r/setup.R

# Compile passenger data (only needs to be done once per year of data)
if test -f "data/passenger.arrow"; then
    echo "***compile_data: passenger data already compiled"
else
    echo "***compile_data: compiling annual passenger data"
    Rscript r/passenger.R
fi

# Compile ride data and merge for each week
for RIDE_DATA in data/Fahrzeiten_*
do
    echo "***compile_data: compiling punctuality data for $RIDE_DATA"
    Rscript r/punctuality.R $RIDE_DATA
    echo "***compile_data:  creating final merge for $RIDE_DATA"
    Rscript r/full_merge.R $RIDE_DATA
done

rm -r data/punctuality_*.arrow
