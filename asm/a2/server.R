# server.R
library(shiny)
library(leaflet)
library(ggplot2) # load ggplot

dat <- read.csv('assignment-02-data-formated.csv')
dat$value <- as.numeric((sub('%', '', dat$value)))
site.lat <- unique(dat[c('location', 'latitude')])
site_order <- order(site.lat$latitude, decreasing = T)
site.lat <- site.lat[site_order,]
dat$location <- factor(dat$location, levels = site.lat$location)
sites <- unique(dat[c('location', 'latitude', 'longitude')])


shinyServer(function(input, output) {
    
    # Return the formula text for printing as a caption
    output$caption <- reactiveText(function() {
        paste("Bleaching for", input$cotype)
    })
    
    output$coralplot <- reactivePlot(function() {
        myData <- dat[dat$coralType == input$cotype,]
        
        p <- ggplot(myData, aes(year, value)) + 
            geom_point(size=1) + facet_wrap(~location, nrow = 1)
        
        p <- p + theme_bw() +
            scale_x_continuous("Year") +
            scale_y_continuous("Bleaching percentage") +
            theme(legend.position = "top", legend.direction = "horizontal")
        
        p <- p + geom_smooth(aes(group = 1),
                             method = "lm",
                             color = "red",
                             formula = y~ poly(x, input$poly),
                             size = 0.6,
                             se = FALSE)
        print(p)
    })
    
    output$baymap <- renderLeaflet ({
            leaflet(data = sites) %>% addTiles() %>%
                addMarkers(~longitude, ~latitude, label= ~as.character(location), 
                       labelOptions = labelOptions(noHide = T, textsize = "10px")) 
        })
    
    }
    
)