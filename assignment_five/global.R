library(maps)

# R Runs this file first before rendering the UI, useful for initial staging of data.

housingData <- read.csv("kingCountyData.csv", sep = ",")
housingData$decade_round <- as.integer(housingData$yr_built / 10)
housingData$decade_built <- housingData$decade_round * 10
dataToAgg <-data.frame("price" = housingData$price,
                       "year_built" = housingData$yr_built,
                       "zipcode" = housingData$zipcode,
                       "decade_built" = housingData$decade_built,
                       "long" = housingData$long,
                       "lat" = housingData$lat,
                       "sqft_living" = housingData$sqft_living)

dataToAgg$priceGroup <- ifelse(dataToAgg$price < 322001, 1,
                               ifelse(dataToAgg$price < 645001, 2,
                                      ifelse(dataToAgg$price < 1300001, 3, 4)))

kingCountyMap <- subset(map_data('county'), subregion == 'king' & region == 'washington')