# ui.R
library(shiny)
library(leaflet)
shinyUI(fluidPage( 
    headerPanel("Bleaching per coral type"),
    sidebarLayout(
        sidebarPanel(
            selectInput("cotype", "Coral type:", 
                        c("Blue Corals" = "blue corals", 
                          "Hard Corals" = "hard corals",
                          "Sea Fans" = "sea fans",
                          "Sea Pens" = "sea pens",
                          "Soft Corals" = "soft corals"
                          )
            ),
            sliderInput("poly",
                        "Degree of smoothing line:",
                        min = 1,
                        max = 7,
                        value = 2)
        ),
        
        mainPanel(
            h3(textOutput("caption")),
            plotOutput("coralplot"),
            leafletOutput("baymap")
        )
    )
))
