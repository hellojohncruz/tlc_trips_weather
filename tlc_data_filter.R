tlc_trips_aug <- read_parquet('fhvhv_tripdata_2022-08.parquet')

tlc_trips_aug <- 
  tlc_trips_aug |>
  mutate(app = ifelse(hvfhs_license_num == 'HV0003', 'Uber', 'Lyft')) |> 
  relocate(app) |> 
  filter(pickup_datetime >= '2022-08-01',
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
  filter(pickup_datetime < '2022-09-01',
         trip_time >= 0,
         trip_time < 18000,
         trip_miles >= 0,
         driver_pay > 0.01,
         base_passenger_fare > 0.01,
         !PULocationID %in% c(264, 265)) |> 
  select(app, pickup_datetime, dropoff_datetime, PULocationID, trip_miles, trip_time, base_passenger_fare)


tlc_trips <- 
  rbind(tlc_trips_aug, tlc_trips_sep)

write_parquet(tlc_trips, 'tlc_trips.parquet')