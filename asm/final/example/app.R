library(ggplot2)
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


ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30),
            
            selectInput("nationality", "Nationality:", 
                        c("USA" = "US player", 
                          "Others" = "Foreign player"
                        )),
            selectInput("period", "Draft period:", 
                        c("before 2002" = "before 2002", 
                          "after 2002" = "after 2002"
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

server <- function(input, output) {
    
    
    output$plot1 <- renderPlot({
        
        ggplot(nba, aes(x=Height_cm,y=Weight)) + geom_point()
        
    })
    
    output$hover_info <- renderPrint({
        if(!is.null(input$plot_hover)){
            hover=input$plot_hover
            dist=sqrt((hover$x-nba$Height_cm)^2+(hover$y-nba$Weight)^2)
            cat("Weight (lb/1000)\n")
            if(min(dist) < 3)
                nba$Player[which.min(dist)]
        }
        
        
    })
}
shinyApp(ui, server)