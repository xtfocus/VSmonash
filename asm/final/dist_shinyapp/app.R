# Shiny app: Height and Weight of NBA players
# Author: Tung Nguyen
# ID 30555418
#

require(reshape2) # for melting
require(shiny)
require(scatterD3)
require(dplyr)
require(ggplot2)

path = ''
# If run in rstudio, uncomment line below
# path = paste(dirname(rstudioapi::getSourceEditorContext()$path), '/', sep='')

nba <- read.csv(paste(path, '../data/nba_height_weight.csv', sep=''))

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
                        )),
            
            actionButton("collect_1", "Choose as first sample"),
            
            actionButton("collect_2", "Choose as second sample"),
            
            actionButton("test", "Do a t-test"),
            
            selectInput("testVal", "Test for:", 
                        c("Height" = "Height_cm",
                          "Weight" = "Weight"
                        )),
            
            textInput("searched_name", "Search a name", "Kobe Bryant")
            
        ),
        
        # Show a plot of the  distribution
        mainPanel(
            h3(textOutput("caption")),
            scatterD3Output("nba_all"),
            plotOutput("density_plot")
        )
        
    ),
    
)


# Define server logic required to draw a histogram
server <- function(input, output) {

  v1 <- reactiveValues(value = 0)
  v2 <- reactiveValues(value = 0)
  
  vec2frame <- function(v1, v2){
    # Convert two vectors v1, v2 of the same unit into a dataframe with two column
    # the first column tells the data source (v1 or v2), the second is the measurement
    
    i = 1
    j <- 1
    col1 <- c()
    col2 <- c()
    id <- c()
    
    while (i  <= length(v1)){
      col1[j] <- "group 1"
      col2[j] <- v1[i]
      id[j] <- j
      i <- i + 1
      j <- j+1
    }
    
    i <- 1
    while (i  <= length(v2)){
      col1[j] <- "group 2"
      col2[j] <- v2[i]
      id[j] <- j
      i <- i + 1
      j <- j+1
    }
    
    df <- melt(data.frame(col1, col2))
    colnames(df) <- c("group", "B", "value")  
    return (select(df, "group", "value"))
  }
  
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
  
  # Define behaviors upon clicking sampling buttons
  observeEvent(input$collect_1, {
    v1$value <- prepare_data()
    showNotification(paste("Selected", input$nationality, 
                           input$period, "as first sample", sep=' '), 
                     duration = 20, type="message")
  })
  
  observeEvent(input$collect_2, {
    v2$value <- prepare_data()
    showNotification(paste("Selected", input$nationality, 
                           input$period, "as second sample", sep=' '), 
                     duration = 20, type="message")
  })
  
  # Foolproof for the test button: show message if not enough samples collected
  observeEvent(input$test, {
    if (length(v1$value) == 1){
      showNotification("Please select the first sample", 
                       duration =5, type = "error")
    }
    
    else if (length(v2$value) == 1){1
      showNotification("Please select the second sample", 
                       duration = 5, type = "error")
    }
    
    else{
      ttest <- t.test(v1$value[,input$testVal], v2$value[,input$testVal])
      p <- ttest$p.value
      showNotification(paste("-----", "Running t-test for", input$testVal, sep="\n"), duration = 20)
      showNotification(paste("p-value =", p, sep=" "), duration = 20)
      showNotification(paste("95% Confidence interval:", ttest$conf.int[1], "-", ttest$conf.int[2]), duration = 20)
      
      # Interpret result of t-test
      if(p < 0.05){
        showNotification( "At significant level 95%, means are not equal", duration = 20)
      }
      
      else{
        showNotification( "At significant level 95%, means are equal", duration = 20)
      }
      
      # Draw density lines to compare sample
      output$density_plot <- renderPlot(width=500, {
        V1 <- as.vector(v1$value[,input$testVal])
        V2 <- as.vector(v2$value[,input$testVal])
        data <- vec2frame(V1, V2)
        ggplot(data, aes(x=value, color=group)) +
          geom_density()
      })
    }
  })
    

    # Reactive caption
    output$caption <- reactiveText(function() {
      if (input$nationality != 'all'){
        paste("Showing ", input$nationality, 's', ' drafted ', input$period, sep='')
      }
      
      else{
        paste("Showing all players", ' drafted ', input$period, sep='')
      }
    })

    output$nba_all <- renderScatterD3({
      
        myData <- prepare_data()
        name = tolower(input$searched_name)
        myData$Names <- ''
        i = 1
        while (i <= length(myData$Names)){
          if (tolower(myData$Player[i]) == name){
            # myData$Names[i] <- toupper(myData$Player[i])
            myData$Names[i] <- as.character(myData$Player[i])
          }
          i <- i + 1
        }
        
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
                  color = "#A94175",
                  lab = Names) 
    })
    
    
}
# Run the application 
shinyApp(ui = ui, server = server)
