#!/usr/bin/env bash

# NOTE: We use "/usr/bin/env" as "shebang" to maximize portability: 
#       it will run the first "bash" binary found on the PATH.

# =======================================================================
# This script will produce a sorted list of "bicycle station names" for 
# "Oslo Bysykkel", showing #bicycles and #docks available at each station.
# 
# The JSON API is documented here: https://oslobysykkel.no/apne-data/sanntid
#
# Basically we get 2 .json-files using curl: Stations info and Availability.
#
# We then use "jq" to get only the fields we need from the .json-files,
# and store the results in 2 tab-separated files (.tsv).
#
# We then join the "station names file" and the "availability file"
# on the common "station_id" field, to create the resulting output (STDOUT).
#
# Each line in the output has 3 tab-separated fields: 
#   station name, available bikes, available docks. 
# ========================================================================

# NOT USED: Testing of date-format: 
# current_date="`date +%Y-%m-%d`";
# current_time="`date +%H:%M:%S`";
# echo "Date:$current_date Time:$current_time"

# DEFINE the FILES and DIRECTORIES that are used in the script

TEMP_OUTPUT_DIR="./temp_output"

# Delete the "output directory" and its contents 
if [ -d "$TEMP_OUTPUT_DIR" ]; then
  rm -rf "$TEMP_OUTPUT_DIR"
fi

mkdir "$TEMP_OUTPUT_DIR"

FILE_1a_STATION_INFORMATION_JSON="$TEMP_OUTPUT_DIR/1a_station_information.json"
FILE_1b_STATION_INFORMATION_TSV="$TEMP_OUTPUT_DIR/1b_station_information.tsv"
FILE_1c_STATION_INFORMATION_TSV_SORTED="$TEMP_OUTPUT_DIR/1c_station_information_SORTED.tsv"

FILE_2a_STATION_STATUS_JSON="$TEMP_OUTPUT_DIR/2a_station_status.json"
FILE_2b_STATION_STATUS_TSV="$TEMP_OUTPUT_DIR/2b_station_status.tsv"
FILE_2c_STATION_STATUS_TSV_SORTED="$TEMP_OUTPUT_DIR/2c_station_status_SORTED.tsv"

FILE_3a_STATION_ID_NAME_AND_AVAILABILITY_TSV="$TEMP_OUTPUT_DIR/3a_station_id_name_and_availability.tsv"
FILE_3b_STATION_NAME_AND_AVAILABILITY_TSV="$TEMP_OUTPUT_DIR/3b_station_name_and_availability.tsv"
FILE_3c_STATION_NAME_AND_AVAILABILITY_TSV_SORTED="$TEMP_OUTPUT_DIR/3c_station_name_and_availability_SORTED.tsv"

FILE_4a_STATION_NAME_AND_AVAILABILITY_PRETTY_PRINTED="$TEMP_OUTPUT_DIR/4a_station_name_and_availability_PRETTY_PRINTED.txt"

# Get list of "bicycle stations" from "Oslo Bysykkel"'s open API
curl -H "Client-Identifier: erlendbleken-devtest" --fail --silent --show-error -o \
  "$FILE_1a_STATION_INFORMATION_JSON" \
  https://gbfs.urbansharing.com/oslobysykkel.no/station_information.json

exitCode=$?

if [ $exitCode -ne 0 ]; then
    echo "==================================================================" >> /dev/stderr
    echo "Det oppstod en FEIL ved forsøk på å hente flg. .json-fil vha curl:" >> /dev/stderr
    echo "   https://gbfs.urbansharing.com/oslobysykkel.no/station_information.json" >> /dev/stderr
    echo "==================================================================" >> /dev/stderr
    exit $exitCode
fi

# Create one line per station, but keep only 2 fields: id, name 
jq -M -r '.data.stations[] | "\(.station_id)\t\(.name)"' \
  "$FILE_1a_STATION_INFORMATION_JSON" > "$FILE_1b_STATION_INFORMATION_TSV"

# Sort lines on the first field (station_id). Also remove duplicate lines (-u: unique option)
sort -u -t$'\t' -k1,1 < "$FILE_1b_STATION_INFORMATION_TSV" \
  > "$FILE_1c_STATION_INFORMATION_TSV_SORTED"

# Get the "stations status" (availability of bikes and locks) from the "open API"
curl -H "Client-Identifier: erlendbleken-devtest" --fail --silent --show-error -o \
  "$FILE_2a_STATION_STATUS_JSON" \
  https://gbfs.urbansharing.com/oslobysykkel.no/station_status.json

exitCode=$?

if [ $exitCode -ne 0 ]; then
    echo "==================================================================" >> /dev/stderr
    echo "Det oppstod en FEIL ved forsøk på å hente flg. .json-fil vha curl:" >> /dev/stderr
    echo "   https://gbfs.urbansharing.com/oslobysykkel.no/station_status.json" >> /dev/stderr
    echo "==================================================================" >> /dev/stderr
    exit $exitCode
fi

# Create one line per station, and keep only 3 fields: id, #bikes, #docks 
jq -M -r '.data.stations[] | "\(.station_id)\t\(.num_bikes_available)\t\(.num_docks_available)"' \
  "$FILE_2a_STATION_STATUS_JSON" > "$FILE_2b_STATION_STATUS_TSV"

# Sort on the first field (station_id). Also remove duplicate lines (-u: unique option)
sort -u -t$'\t' -k1,1 < "$FILE_2b_STATION_STATUS_TSV" > "$FILE_2c_STATION_STATUS_TSV_SORTED"

# Join the 2 sorted files on "column 1" (station_id)
join -t $'\t' -1 1 -2 1 "$FILE_1c_STATION_INFORMATION_TSV_SORTED" "$FILE_2c_STATION_STATUS_TSV_SORTED" \
  > "$FILE_3a_STATION_ID_NAME_AND_AVAILABILITY_TSV"

# Remove the first column 1 (station_id), i.e. keep only columns 2, 3 and 4.
cut -f2-4  < "$FILE_3a_STATION_ID_NAME_AND_AVAILABILITY_TSV" \
  > "$FILE_3b_STATION_NAME_AND_AVAILABILITY_TSV"

# Sort on the first field (station_name). The "-u" option (unique) should not be necessary..
sort -t$'\t' -k1,1 < "$FILE_3b_STATION_NAME_AND_AVAILABILITY_TSV" \
  > "$FILE_3c_STATION_NAME_AND_AVAILABILITY_TSV_SORTED"

# Add a "Header line", then pretty print the tab-separated file (.tsv) 
# into a file with 3 "aligned columns" (separated by spaces).
#
# NOTE: The "-s" option to the "column" command specifies column delimitter character.

# NOT USED: could not find "column" util for "Alpine Linux" (used by Docker).
# 
#(printf "STATION NAME\t#BIKES\t#DOCKS\n"; \
#  cat "$FILE_3c_STATION_NAME_AND_AVAILABILITY_TSV_SORTED") \
#  | column -s$'\t' -t > "$FILE_4a_STATION_NAME_AND_AVAILABILITY_PRETTY_PRINTED"

# Print the header line
echo "STATION NAME                    #BIKES  #DOCKS" \
  > "$FILE_4a_STATION_NAME_AND_AVAILABILITY_PRETTY_PRINTED"

# "Pretty print" each line into 3 columns
cat "$FILE_3c_STATION_NAME_AND_AVAILABILITY_TSV_SORTED" \
  | awk 'BEGIN {FS="\t"}; {printf "%-30s\t%.2d\t%2.2d\n", substr($1, 0, 30), $2, $3}' \
  >> "$FILE_4a_STATION_NAME_AND_AVAILABILITY_PRETTY_PRINTED"

# Print the "pretty printed" result to STDOUT
cat "$FILE_4a_STATION_NAME_AND_AVAILABILITY_PRETTY_PRINTED"

