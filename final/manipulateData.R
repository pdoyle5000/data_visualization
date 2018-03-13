# Filter data based on time slider
uiFilter <- function(rawData, uiInput) {
  filteredData <- subset(rawData,
                         rawData$day >= uiInput[1] & rawData$day <= uiInput[2])
  return(filteredData)
}

# Filter data based on plugin prefix
pluginFilter <- function(pluginData, pluginPrefix = "ALL") {
  if (pluginPrefix == "org.gradle" | pluginPrefix == "com.idexx") {
    return(subset(pluginData, grepl(pluginPrefix, plugin)))
  }
  if (pluginPrefix == "other") {
    return(subset(pluginData, !grepl("org.gradle|com.idexx", plugin)))
  }
  return(pluginData)
}

# Remove low frequency data from plottable set
trimLowFrequencies <- function(data, fieldToCount) {
  countedBuildData <- count(data[[fieldToCount]])
  shavedCountedBuildData <- subset(countedBuildData, freq > 9)
  listOfQualifiedProjects <- shavedCountedBuildData$x
  return(subset(data, data[[fieldToCount]] %in% listOfQualifiedProjects))
}

# Remove high frequency data according to frequency slider.
trimHighFrequencies <- function(data, fieldToCount, trimThreshold) {
  countedBuildData <- count(data[[fieldToCount]])
  shavedCountedBuildData <- subset(countedBuildData, freq <= trimThreshold)
  listOfQualifiedProjects <- shavedCountedBuildData$x
  return(subset(data, data[[fieldToCount]] %in% listOfQualifiedProjects))
}

# Get max plugin freuency for plot and slider bounds.
maxPluginCount <- function(data) {
  countedData <- count(data$plugin)
  return(max(countedData$freq))
  
}

# Text blurb showing time range of plot shown
perDayTextOutput <- function(timeInput) {
  return(sprintf(
    "This is a chart displaying the number of project builds per day from: %s to %s", timeInput[1], timeInput[2]))
}

# Text blurb showing time range of plot shown
buildTimesTextOutput <- function(timeInput) {
  return(sprintf(
    "This is a chart displaying project build time data from: %s to %s", timeInput[1], timeInput[2]))
}

# Text blurb showing time range of plot shown
pluginUsageTextOutput <- function(timeInput) {
  return(sprintf(
    "This is a chart displaying project plugin usage data from: %s to %s", timeInput[1], timeInput[2]))
}