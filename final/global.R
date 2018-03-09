install.packages('jsonlite')
install.packages('anytime')
library(jsonlite)
library(anytime)
inputJson <- jsonlite::fromJSON("flat_all2.json")
inputPlugins <- jsonlite::fromJSON("plugins.json")

# TODO List
# Clean go script
# Write Word Doc
# Build R Server App
# Dockerize (if time, serve it up!)
# Slides

buildData <- inputJson
buildData$gradleVersion <- factor(buildData$gradleVersion)
buildData$pluginVersion <- factor(buildData$pluginVersion)
buildData$project <- factor(buildData$project)
buildData$buildStart <- anytime(buildData$buildStart/1000)
buildData$buildEnd <- anytime(buildData$buildEnd/1000)
buildData$duration <- as.numeric(buildData$buildEnd - buildData$buildStart, units = "secs")

pluginsListing <- inputPlugins
pluginsListing$project <- factor(inputPlugins$project)
pluginsListing$plugin <- factor(inputPlugins$plugin)

summary(pluginsListing$plugin)
# test breaking down plugins list
mergeLists <- function(pluginLists) {
  
  #allPlugins <- do.call(c, unlist(pluginLists, recursive=FALSE))
}

options(scipen=999)
print(test2$buildStart[1])
anytime(test2$buildStart[1])

anytime(1519848561681 / 1000)
anytime(1519848561)

library(tidyr)
t#nest <- unnest(buildData$plugins, plugins)
biglist <- mergeLists(buildData$plugins)
#print(testInputJson$plugins[2])