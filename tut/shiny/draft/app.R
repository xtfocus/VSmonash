#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(scatterD3)
require(dplyr)
require(tidyr)
library(plyr)
setwd('~/units/VSmonash/asm/EDA/meat/')
nba <- read.csv('phythro_nba.csv')
nba[nba$Draft_Round=='Undrafted',]$Draft_Round <- NA
nba$Draft_Round <- as.numeric(as.character(nba$Draft_Round))
nba[nba$Draft_Number=='Undrafted',]$Draft_Number <- NA
nba[nba$Wingspan=='',]$Wingspan <- NA
df <- data.frame(nba$Wingspan)
df <- df %>% separate(nba.Wingspan, c('feet', 'inches'), "'", convert = TRUE) %>% 
    mutate(cm = (12*feet + inches)*2.54)
nba$Wingspan_cm <- df$cm

nba$period = NA
nba[nba$Draft_Year < 2002,]$period = 'before 2002'
nba[nba$Draft_Year >= 2002,]$period = 'after 2002'
nba$period <- as.factor(nba$period)
nba$Nationality = NA
nba[nba$Country == 'USA',]$Nationality = 'US player'
nba[nba$Country != 'USA',]$Nationality = 'Foreign player'
nba$Nationality <- as.factor(nba$Nationality)


completeFun <- function(data, desiredCols) {
    completeVec <- complete.cases(data[, desiredCols])
    return(data[completeVec, ])
}

# Define UI for application that draws a histogram
ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            selectInput("nationality", "Nationality:", 
                        c("All" = "all",
                          "USA" = "US player", 
                          "Others" = "Foreign player"
                        )),
            selectInput("period", "Draft period:", 
                        c("All" = "all",
                          "before 2002" = "before 2002", 
                          "after 2002" = "after 2002"
                        ))
        ),
        
        # Show a plot of the  distribution
        mainPanel(
            h3(textOutput("caption")),
            scatterD3Output("nba_all")
        )
        
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    
    output$caption <- reactiveText(function() {
        paste("Showing ", input$nationality, 's', ' drafted ', input$period, sep='')
    })
    
    prepare_data <- function(){
        if (input$period == 'all' & input$nationality == 'all'){
            return(nba)
        }
        else if (input$period == 'all'){
            return(nba[nba$Nationality == input$nationality,])
        }
        else if (input$nationality == 'all'){
            return(myData <- nba[nba$period == input$period,])
        }
        else {
            myData <- nba[nba$period == input$period,]
            return(myData[myData$Nationality == input$nationality,])
        }
    }
    
    output$nba_all <- renderScatterD3( {
        myData <- prepare_data()
        scatterD3(myData, x=Height_cm, y=Weight, 
                  point_opacity = .4,
                  hover_size = 3,
                  hover_opacity = 1,
                  tooltip_text = paste(myData$Player, myData$Height, 'ft', myData$Weight, 'lbs', 'from', myData$Country),
                  xlim = c(170,235),
                  ylim = c(140,340),
                  axes_font_size = "120%",
                  ellipses = TRUE,
                  xlab = 'Height in cm',
                  ylab = 'Weight in lbs',
                  color = "#A94175") 
    })
    
    
}
# Run the application 
shinyApp(ui = ui, server = server)
