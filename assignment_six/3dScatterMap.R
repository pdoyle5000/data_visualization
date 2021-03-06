install.packages('tidyverse')
install.packages('RCurl')
install.packages('maps')
library(tidyverse)
library(plotly)
library(RCurl)


# Create Data
rawCsv <- getURL("https://raw.githubusercontent.com/pdoyle5000/data_visualization/master/kingCountyData.csv")


houseData <- read.csv(
  text = rawCsv, sep = ",")

houseData$priceGroup <- ifelse(houseData$price < 322001, 1,
                               ifelse(houseData$price < 645001, 2,
                                      ifelse(houseData$price < 1300001, 3, 4)))

kingCountyMap <- subset(map_data('county'), subregion == 'king' & region == 'washington')

addT <- function(m, year) {
  library(plotly)
  traceToCreate <- m %>% add_trace(
    type="scatter3d",
    mode="lines", 
    x = kingCountyMap$long, 
    y = kingCountyMap$lat, 
    z = year, 
    inherit = FALSE,
    showlegend = FALSE,
    hoverinfo = 'none',
    color = 'black',
    opacity = .8)
  return(traceToCreate)
}

# Create Chart
plotlyMap <- plot_ly(houseData, 
                     x = ~long, 
                     y = ~lat, 
                     z = ~yr_built,
                     showlegend = TRUE,
                     color = ~priceGroup,
                     colors = c("#0AC5FF", 
                                "#0793BF", 
                                "#05627F", 
                                "#02313F", 
                                "#000000"), 
                     opacity =.2,
                     marker = list(size=4)) %>%
  add_markers(
    showlegend = FALSE,
    text = ~paste(paste("Built:", yr_built), paste("Price:", price), sep = "<br />"),
    hoverinfo = 'text'
  ) %>%
  layout(title = "King County Housing Prices By Year Built<br /><i>Darker color means larger price.</i>",
         scene = list(xaxis = list(title = 'long'),
                      yaxis = list(title = 'lat', autorange = "reversed"),
                      zaxis = list(title = 'year built', autorange = "reversed",
                                   range = c(1900,2015))))
  years <- c(1900, 1923, 1946, 1969, 1992, 2015)
  for (year in years) {
    plotlyMap <- addT(plotlyMap, year)
  }

plotlyMap