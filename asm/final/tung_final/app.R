#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            sliderInput("height_slider",
                        label = h3("Height range"),
                        min = 170,
                        max = 230,
                        value = c(170, 230)),

            sliderInput("per_slider",
                        label = h3("PER range"),
                        min = 170,
                        max = 230,
                        value = c(170, 230)),
            
            selectInput("nationality", "Nationality:", 
                        c("USA" = "US player", 
                          "Others" = "Foreign player",
                          "All" = "all"
                        )),
            selectInput("period", "Draft period:", 
                        c("before 2002" = "before 2002", 
                          "after 2002" = "after 2002",
                          "All" = "all"
                        ))
        ),
        
        # Show a plot of the  distribution
        mainPanel(
            h3(textOutput("caption")),
            plotOutput("nba_all", hover = hoverOpts(id ="plot_hover"))
        )
        
    ),
    fluidRow(
        column(width = 5,
               verbatimTextOutput("hover_info")
        )
    )
)

# Define server logic required to draw a histogram
require(dplyr)
require(ggplot2)
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

nba <- completeFun(nba, "Country")
myData <- nba

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
    
    output$nba_all <- reactivePlot(function() {
        myData <- prepare_data()
        # 
        # myData <- nba[nba$period == input$period,]
        # myData <- myData[myData$Nationality == input$nationality,]
        p1<-ggplot(myData, aes(Height_cm, Weight)) + geom_point(color='orange', size = 2, alpha=.5)
        outliers <- c('Tyler Ulis', 'Dee Brown')
        p2 <- p1 + geom_text(aes(label=Player), hjust='inward',
                             data=myData[myData$Player %in% outliers, ]) + geom_point(data=myData[myData$Player %in% outliers, ], color='green')
        p3 <- p2 +
            geom_smooth(aes(group = 1),
                        method = "lm",
                        color = "black",
                        formula = y~ poly(x, 2),
                        se = T)

        p4 <- p3  +
            scale_x_continuous("Height in cm") +
            scale_y_continuous("Weight in lbs") +
            theme(legend.position = "top", legend.direction = "horizontal") + scale_color_gradientn(colours = rainbow(5))

        p4 <- p4 + xlim(170, 230) + ylim(165, 325)
        p4
        
    })
    
    
    output$hover_info <- renderPrint({
        # myData <- nba[nba$period == input$period,]
        # myData <- myData[myData$Nationality == input$nationality,]
        myData <- prepare_data()
        if(!is.null(input$plot_hover)){
            hover <- input$plot_hover
            dist=sqrt((hover$x-myData$Height_cm)^2+(hover$y-myData$Weight)^2)
            cat("Player's name:")
            if(min(dist) < 2){
                x1 <- as.character(myData$Player[which.min(dist)])
                x2 <- as.character(myData$Country[which.min(dist)])
                paste(x1, x2)
                
            }
        }


    })
}

# Run the application 
shinyApp(ui = ui, server = server)
