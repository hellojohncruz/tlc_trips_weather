# The NYC Taxi and Limousine Commission provides a data dictionary ['here'](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_hvfhs.pdf). The rideshare app companies such as Uber is coded as (HV0003) and Lyft (HV0005). 
# 
# **Note:** The data has been cleaned and filtered using the R script *tlc_data_filter.R* that is within the same GitHub repo. Here are the changes:
#   
#   - All the trips performed in August were found to be within two separate files for both August and September.
# - Trips were filtered because of huge outliers that were present such as:
#   - Trip time had to be >0 seconds and <= 5 hours. 
# - Trip miles had to be >= 0.
# - Driver pay > $0.01.cd
# - Base passenger fare > $0.01.
# - Pickup locations had to be within the NYC region and not unknown/outside of it.

library(tidyverse)
library(arrow)
library(weathermetrics)
library(lubridate)

tlc_trips_aug <- read_parquet('fhvhv_tripdata_2022-08.parquet')

tlc_trips_aug <- 
  tlc_trips_aug |>
  mutate(app = ifelse(hvfhs_license_num == 'HV0003', 'Uber', 'Lyft')) |> 
  relocate(app) |> 
  filter(pickup_datetime > '2022-07-31 23:59:59',
         trip_time >= 0,
         trip_time < 18000,
         trip_miles >= 0,
         driver_pay > 0.01,
         base_passenger_fare > 0.01,
         !PULocationID %in% c(264, 265)) |> 
  select(app, pickup_datetime, dropoff_datetime, PULocationID, trip_miles, trip_time, base_passenger_fare)

tlc_trips_sep <- read_parquet('fhvhv_tripdata_2022-09.parquet')

tlc_trips_sep <- 
  tlc_trips_sep |>
  mutate(app = ifelse(hvfhs_license_num == 'HV0003', 'Uber', 'Lyft')) |> 
  relocate(app) |>
  filter(pickup_datetime < '2022-09-01 00:00:00',
         trip_time >= 0,
         trip_time < 18000,
         trip_miles >= 0,
         driver_pay > 0.01,
         base_passenger_fare > 0.01,
         !PULocationID %in% c(264, 265)) |> 
  select(app, pickup_datetime, dropoff_datetime, PULocationID, trip_miles, trip_time, base_passenger_fare)


tlc_trips <- 
  rbind(tlc_trips_aug, tlc_trips_sep)

tlc_trips <- 
  tlc_trips |> 
  mutate(pickup_datetime = force_tz(pickup_datetime, tzone = 'America/New_York'),
         pickup_floor = floor_date(pickup_datetime, unit = "hour"))

write_parquet(tlc_trips, 'tlc_trips.parquet')