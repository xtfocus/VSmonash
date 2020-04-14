require(dplyr)
require(leaflet)

# read data
dat <- read.csv('assignment-02-data-formated.csv')

# get site location, lat and lon
sites <- unique(dat[c('location', 'latitude', 'longitude')])

# create map
leaflet(data = sites) %>% addTiles() %>%
  addMarkers(~longitude, ~latitude, label= ~as.character(location), 
             labelOptions = labelOptions(noHide = T, textsize = "10px")) 