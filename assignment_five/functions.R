library(ggplot2)
library(scales)

# This filters the data according to the slider and zip inputs.
filterData <-function(inputData, tScale, tSlider, zip) {
  filtered <- subset(inputData,
                         inputData[[tScale]] >= tSlider[1] & inputData[[tScale]] <= tSlider[2])
  
  if (zip != "") {
    filtered <- subset(filtered, zipcode == zip)
  }
  
  return(filtered)
}

# Draws the bar chart using pre-filtered data input and a time magnitude input.
drawBarChart <-function(inputData, tScale){
  precomputeForColors <- aggregate(inputData, by=list(inputData[[tScale]]), FUN=mean)
  avgPrice <- mean(inputData$price)
  priceBarChart <- ggplot(inputData) +
    geom_bar(aes(x = inputData[[tScale]], y = price),
             position = 'dodge',
             stat = 'summary',
             fun.y = 'mean',
             fill = 'darkred',
             alpha = ifelse(precomputeForColors$price > avgPrice,.8,.3)) +
    coord_flip() +
    theme(panel.grid.major.y = element_blank(), 
          plot.title = element_text(hjust = 0.5)) +
    scale_y_continuous(name="Home Price ($)",
                       breaks=seq(0, 8000000, 100000),
                       labels = comma, expand = c(0,0)) +
    scale_x_continuous(name="Decade",
                       expand=c(0,0)) +
    geom_hline(yintercept = avgPrice,
               linetype='dashed',
               color='darkred',
               size = 1.0) +
    geom_text(data=data.frame(x=median(inputData[[tScale]]),y=avgPrice + 20000),
              aes(x, y),
              label='Avg Price',
              vjust=-1,
              size = 4,
              fontface = 'bold',
              color = 'darkred') +
    geom_text(data=data.frame(x=median(inputData[[tScale]]),y=avgPrice + 20000),
              aes(x, y),
              fontface = 'bold',
              label=sprintf('$%i', as.integer(avgPrice)), vjust=.5, size = 3.5, color = 'darkred')
  
  return(priceBarChart)
}

# Draws the washington state map and plots home pricing using prefiltered data.
drawCountyMap <- function(inputData) {
  kingCountyMap <- ggplot(data = kingCountyMap, group = group, mapping = aes(x = long, y = lat)) + 
      coord_fixed(1.3) + 
      geom_polygon(color = "darkgray",
                   alpha = .7,
                   size = 1,
                   fill = "#ffe3ba",
                   group = kingCountyMap$group) +
      geom_point(data = inputData,
                 size = .7,
                 alpha = .8,
                 aes(x = long + .04,
                     y = lat - .015,
                     color = priceGroup)) +
      scale_color_gradient(low="lightgray",
                           high="darkred",
                           #name = legendTitle,
                           labels = c("$75K-$322K", "$322K-$645K", "$645k-$1.3M", "Over $1.3M")) +
      theme_void() +
      theme(panel.background = element_rect(fill ='#d3d3d3', color = 'black')) +
      theme(plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5),
            plot.caption = element_text(size = 12, face = "italic", hjust = 0.5),
            legend.position="left")
  
    return(kingCountyMap)
}

# Draws square footage price comparison graphs using prefilterd data.
drawLineCharts <- function(inputData) {
  livingVPrice <- data.frame("price" = inputData$price, "sqft_living" = inputData$sqft_living)
  avgSqftForPrice <- aggregate(livingVPrice, by=list(livingVPrice$price), FUN=mean)
  priceVfootageCheaper <- subset(avgSqftForPrice, price < mean(price) + sd(price))
  priceVfootageExpensive <- subset(avgSqftForPrice, price >= mean(price) + sd(price))
  
  CheaperPriceChart <- ggplot(
    priceVfootageCheaper, aes(x = price, y = sqft_living)) + 
    geom_point(alpha = .1, size = .6) + 
    geom_line(method = 'loess',
              stat = 'smooth',
              color = "orange",
              size = 2.5,
              alpha = .5,
              se = FALSE) +
    theme_minimal() + 
    ggtitle('$0-$1,250,000') +
    scale_y_continuous(name = "Living Space (sq.ft.)",
                       breaks = seq(0, 8000, 1000),
                       labels = comma,
                       expand = c(0,0)) +
    scale_x_continuous(name = "Average Price ($)",
                       breaks = seq(0, 1250000, 200000),
                       labels = comma,
                       expand = c(0,0))
  
  ExpensivePriceChart <- ggplot(
    priceVfootageExpensive, aes(x = price, y = sqft_living)) + 
    geom_point(alpha = .2, size = .6) + 
    geom_line(method = 'loess',
              stat = 'smooth',
              color = "orange",
              size = 2.5,
              alpha = .5,
              se = FALSE) +
    theme_minimal() + 
    ggtitle('$1,250,000+') +
    scale_y_continuous(name = "Living Space (sq.ft.)",
                       breaks = seq(0, 14000, 2000),
                       labels = comma,
                       expand = c(0,0)) +
    scale_x_continuous(name = "Average Price ($)",
                       breaks = seq(0, 8000000, 1000000),
                       labels = comma,
                       expand = c(0,0))
  return(grid.arrange(
          CheaperPriceChart,
          ExpensivePriceChart,
          nrow = 2,
          ncol = 1))
}