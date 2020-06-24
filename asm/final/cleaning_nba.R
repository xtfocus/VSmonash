# clean nba
require(dplyr)
require(tidyr)
library(plyr)

setwd('~/units/VSmonash/asm/EDA/meat/')
nba <- read.csv('~/units/VSmonash/asm/EDA/meat/nba_4shiny')
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

write.csv(nba, "~/units/VSmonash/asm/EDA/meat/nba_4shiny", row.names = FALSE)
