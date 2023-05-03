## Data Preparation

# **Load Historical Weather Data**
# 
# **Calculate Heat Index**
#   
# The measurements for the United States is generally in Fahrenheit. 
# The weather data will be converted from Celsius to Fahrenheit using the *weathermetrics* library. 
# 
# - Relative humidity is calculated using the temperature and dewpoint temperature.
# - Heat index is calculated using the temperature and relative humidity. 
# weather <- read_csv('oikolabs.csv') |> 
#   janitor::clean_names()
# 
# **Day of Week**
#   
# Using the *lubridate* library, we will determine the day of the week and transform the data type with factor levels. 
# The datetime_utc will also be updated to New York's local time to match the trip records.

library(tidyverse)
library(arrow)
library(weathermetrics)
library(lubridate)

weather <- read_csv('oikolabs.csv') |> 
  janitor::clean_names()

weather <- 
  weather |> 
  mutate(temp_deg_f = celsius.to.fahrenheit(temperature_deg_c),
         rel_humidity = dewpoint.to.humidity(t = temperature_deg_c, 
                                             dp = dewpoint_temperature_deg_c, 
                                             temperature.metric = "celsius"),
         heat_idx = heat.index(t = temp_deg_f, 
                               rh = rel_humidity),
         total_precipitation_mm_of_water_equivalent = total_precipitation_mm_of_water_equivalent / 25.4) |> 
  rename(total_precip = total_precipitation_mm_of_water_equivalent)

weather_trim <-
  weather |> 
  mutate(day_of_week = wday(datetime_utc, label = TRUE, week_start = 1, abbr = FALSE),
         day_of_week = as.factor(day_of_week),
         datetime_ny = with_tz(datetime_utc, "America/New_York")) |>
  relocate(datetime_ny) |> 
  select(datetime_ny, temp_deg_f, rel_humidity, heat_idx, total_precip) |> 
  filter(between(datetime_ny, as.Date("2022-07-31"),
         as.Date("2022-09-01")))

write_parquet(weather_trim, 'weather.parquet')
