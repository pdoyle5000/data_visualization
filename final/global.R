# These dependencies are needed outside of the Container.

# install.packages('jsonlite')
# install.packages('anytime')
# install.packages('ggplot2')
# install.packages('plotly')
# install.packages('shiny')
# install.packages("shinythemes")

library(shiny)
library(jsonlite)
library(anytime)
library(ggplot2)
library(forcats)
library(tidyr)
library(plyr)
library(plotly)
library(shinythemes)
source('gradleCharts.R')
source('manipulateData.R')

# load data
# these files will be staged by to GO app, (cadence TBD Cron)
inputJson <- jsonlite::fromJSON("data/build_data.json")
inputPlugins <- jsonlite::fromJSON("data/plugin_data.json")

# Format data
buildData <-inputJson
buildData$gradleVersion <- factor(buildData$gradleVersion)
buildData$project <- factor(buildData$project)
buildData$buildStart <- anytime(buildData$buildStart/1000)
buildData$buildEnd <- anytime(buildData$buildEnd/1000)
buildData$duration <- abs(as.numeric(buildData$buildEnd - buildData$buildStart, units = "mins"))
buildData$day <- as.Date(trunc(buildData$buildStart, "days"), origin = "1970-01-01")

pluginsListing <- inputPlugins
pluginsListing$Projects <- factor(inputPlugins$project)
pluginsListing$plugin <- factor(inputPlugins$plugin)
pluginsListing$timestamp <- anytime(as.numeric(inputPlugins$timestamp)/1000)
pluginsListing$day <- as.Date(trunc(pluginsListing$timestamp, "days"), origin = "1970-01-01")

pluginCount <- maxPluginCount(pluginsListing)
