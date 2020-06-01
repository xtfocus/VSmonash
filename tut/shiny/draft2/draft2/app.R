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
                        min = 180,
                        max = 230,
                        value = c(180, 230)),
            
            sliderInput("per_slider",
                        label = h3("PER range"),
                        min = 2,
                        max = 30,
                        value = c(2, 30)),
            
            selectInput("nationality", "Nationality:", 
                        c("USA" = "US player", 
                          "Others" = "Foreign player",
                          "All" = "all"
                        )),
            selectInput("period", "Draft period:", 
                        c("before 2002" = "before 2002", 
                          "after 2002" = "after 2002",
                          "All" = "all"
                        )),
            selectInput("fitline", "Fitting:", 
                        c("on" = "on", 
                          "off" = "off"
                        ))
        ),
        
        # Show a plot of the  distribution
        mainPanel(
            h3(textOutput("caption")),
            plotOutput("plot1", hover = hoverOpts(id ="plot_hover"))
        )
        
    ),
    fluidRow(
        column(width = 5,
               verbatimTextOutput("hover_info")
        )
    )
)

require(ggplot2)

setwd('~/units/VSmonash/asm/EDA/meat/')
data <- read.csv('short_PER_1819.csv')

server <- function(input, output) {
    
    
    # output$caption <- reactiveText(function() {
    #     paste("Showing ", input$nationality, 's', ' drafted ', input$period, sep='')
    # })
    

    output$plot1 <- reactivePlot(function() {
        # min and max height of range
        min_H <- input$height_slider[1]
        max_H <- input$height_slider[2]
        # min and max per of range
        min_P <- input$per_slider[1]
        max_P <- input$per_slider[2]
        
        myData <- data[data$Height_cm<= max_H & data$Height_cm>=min_H,]
        myData <- myData[myData$PER<= max_P & myData$PER>=min_P,]
        
        p1<-ggplot(myData, aes(Height_cm, PER, color=Height_cm)) + geom_point(alpha = .4)  + xlim(180, 230) + ylim(1, 30)
        
        p4 <- p1 +
            theme(legend.position = "top", legend.direction = "horizontal") + scale_color_gradient(low = "#0091ff", high = "#f0650e")
        
        if(input$fitline == 'on'){
            p4 <- p4 + geom_smooth(aes(group = 1),
                                   method = "lm",
                                   color = "black",
                                   formula = y~ poly(x, 2),
                                   se = T)
        }
        else{
            
        }
        p4
    })
    
    
    output$hover_info <- renderPrint({
        # min and max height of range
        min_H <- input$height_slider[1]
        max_H <- input$height_slider[2]
        # min and max per of range
        min_P <- input$per_slider[1]
        max_P <- input$per_slider[2]
        
        myData <- data[data$Height_cm<= max_H & data$Height_cm>=min_H,]
        myData <- myData[myData$PER<= max_P & myData$PER>=min_P,]
        
        if(!is.null(input$plot_hover)){
            hover <- input$plot_hover
            dist=sqrt((hover$x-myData$Height_cm)^2+(hover$y-myData$PER)^2)
            cat("Player's name:")
            if(min(dist) < 2){
                as.character(myData$PLAYER[which.min(dist)])
            }
        }


    })
}

# Run the application 
shinyApp(ui = ui, server = server)
