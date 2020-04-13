dat <- read.csv('assignment-02-data-formated.csv')
sites <- unique(dat[c('location', 'latitude', 'longitude')])
leaflet(data = sites) %>% addTiles() %>%
  addMarkers(~longitude, ~latitude, label= ~as.character(location), 
             labelOptions = labelOptions(noHide = T, textsize = "10px")) 