# Shiny app: Height and PER index of NBA players season 201818-19
# Author: Tung Nguyen
# ID 30555418
#

require(shiny)
require(ggplot2)

path = ''
# If run in rstudio, uncomment line below
# path = paste(dirname(rstudioapi::getSourceEditorContext()$path), '/', sep='')

data <- read.csv(paste(path, '../data/short_PER_1819.csv', sep=''))

# Define UI for application that draws a histogram
ui <- fluidPage(
  
    sidebarLayout(
  
            sidebarPanel(
      
                    sliderInput("height_slider",
                        label = h3("Height range (cm)"),
                        min = 180,
                        max = 230,
                        value = c(180, 230)),
            
            
                    sliderInput("per_slider",
                        label = h3("PER range"),
                        min = 2,
                        max = 32,
                        value = c(2, 32)),
            
            
                    selectInput("team", "Team:", 
                        c("All" = "All",
                            "Milwaukee Bucks" = "MIL", 
                          "Houston Rockets" = "HOU",
                          "New Orleans Pelicans" = "NO",
                          "Minnesota Timberwolves" = "MIN",
                          "Denver Nuggets" = "DEN",
                          "Philadelphia 76ers" = "PHI",
                          "Toronto Raptors" = "TOR",
                          "Los Angeles Lakers" = "LAL",
                          "Orlando Magic" = "ORL",
                          "Utah Jazz" = "UTAH",
                          "Golden State Warriors" = "GS",
                          "Boston Celtics" = "BOS",
                          "Los Angeles Clippers" = "LAC",
                          "Portland Trail Blazers" = "POR",
                          "Miami Heat" = "MIA",
                          "Detroit Pistons" = "DET",
                          "Oklahoma City Thunder" = "OKC",
                          "San Antonio Spurs" = "SA",
                          "New York Knicks" = "NY",
                          "Indiana Pacers" = "IND",
                          "Atlanta Hawks" = "ATL",
                          "Charlotte Hornets" = "CHA",
                          "Memphis Grizzlies" = "MEM",
                          "Washington Wizards" = "WSH",
                          "Phoenix Suns" = "PHX",
                          "Dallas Mavericks" = "DAL",
                          "Cleveland Cavaliers" = "CLE",
                          "Brooklyn Nets" = "BKN",
                          "Sacramento Kings" = "SAC",
                          "Chicago Bulls" = "CHI"
                        )),
        
            
                    selectInput("fitline", "Fitting:", 
                        c("on" = "on", 
                          "off" = "off"
                        )),
            
                    textInput("searched_name", "Search a name", "LeBron James")
                    ),
        
        mainPanel(
            h3(textOutput("caption")),
            plotOutput("plot1", hover = hoverOpts(id ="plot_hover")),
            plotOutput("plot2")
            )
        
    
        ),
    
    fluidRow(
        column(width = 5,
               verbatimTextOutput("hover_info")
        )
    )
)



server <- function(input, output) {
  
    output$caption <- reactiveText(function() {
        paste("Showing PER and Height information of ", input$team, sep='')
    })
    
    cleaning <- function(){
        # Cleaning data
        # get min and max of height defined by slider
        min_H <- input$height_slider[1]
        max_H <- input$height_slider[2]
        
        # get min and max of range defined by slider
        min_P <- input$per_slider[1]
        max_P <- input$per_slider[2]
        
        if(input$team != 'All')
        {
            myData <- data[data$TEAM == input$team,]
        }
        else{
            myData <- data
        }
        myData <- myData[myData$Height_cm<= max_H & myData$Height_cm>=min_H,]
        myData <- myData[myData$PER<= max_P & myData$PER>=min_P,]
        return (myData)
    }
    
    myTheme <- theme(
      plot.title = element_text(size=16, face="bold.italic"),
        axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14, face="bold"),
        axis.text = element_text(size=14, face="bold")
    )
    
    output$plot2 <- reactivePlot(function(){
        myData <- cleaning()

        ggplot(myData, aes(y=PER)) + geom_boxplot() +  coord_flip() + 
          ggtitle("Distribution of PER") + ylim(0, 32) + myTheme + 
          theme(axis.title.y=element_blank(),
                axis.text.y=element_blank(),
                axis.ticks.y=element_blank())
        
    })
    output$plot1 <- reactivePlot(function() {
        myData <- cleaning()
        outliers <- tolower(input$searched_name)
        
        p1<-ggplot(myData, aes(Height_cm, PER, colour=Height_cm)) +
          geom_point(alpha = .4, size=3)  + xlim(180, 230) + ylim(1, 32) + 
          geom_text(aes(label=PLAYER), hjust='inward',
                    data=myData[tolower(myData$PLAYER) %in% outliers, ]) +
          geom_point(data=myData[tolower(myData$PLAYER) %in% outliers, ], color='green')
        
        p4 <- p1 + theme(legend.position = "top", legend.direction = "horizontal") + 
          scale_color_gradient(low = "#0091ff", high = "#f0650e")
        
        # Toggle fitting line
        if(input$fitline == 'on'){
            p4 <- p4 + geom_smooth(aes(group = 1),
                                   method = "lm",
                                   color = "black",
                                   formula = y~ poly(x, 2),
                                   se = T)
        }
        else{
            # do nothing
        }
        
        p4 + ggtitle("PER vs Height (cm)") + myTheme
        
    })
    
    
    output$hover_info <- renderPrint({
      
        myData <- cleaning()
        
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
