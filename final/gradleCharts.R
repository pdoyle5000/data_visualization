# Custom theme for the charts to fit well with Dashboard/UI
darkTheme <- function(titleHAdjust = 0) {
  t <- theme(plot.background = element_rect(fill = '#302d2d', 
                                           color = '#8e8d8d'),
            panel.background = element_rect( fill = '#3d3a3a',
                                             color = '#777777'),
            panel.grid.major = element_line(color = '#660b0b'),
            panel.grid.minor = element_blank(),
            panel.border = element_rect(color = 'white',
                                        fill = NA,
                                        size = 1.5),
            axis.text.x = element_text(color = 'white'),
            axis.text.y = element_text(color = 'white'),
            axis.title.x = element_text(color = 'white', 
                                        face = 'bold'),
            axis.title.y = element_text(color = 'white', 
                                        face = 'bold'),
            plot.caption = element_text(color = 'white',
                                        size = 10,
                                        face = 'italic'),
            plot.title = element_text(color = 'white', 
                                     face = 'bold',
                                     size = 16,
                                     hjust = titleHAdjust),
            legend.title = element_text(color = 'white'),
            legend.text = element_text(color = 'white'),
            legend.background = element_rect(fill = '#302d2d'))
  return(t)
}

# This Viz will display a bar for each plugin and be split on project.
generatePluginChart <- function(pluginData) {
  p <- ggplot(pluginData[order(pluginData$Projects, decreasing = T),],
              aes(x = fct_rev(fct_infreq(plugin)), 
                  fill = Projects, 
                  color = Projects)) + 
    layer(geom = "bar", 
          stat = "count", 
          position = "identity") + 
    coord_flip() + 
    scale_fill_hue(l=50) +
    labs(x = "Gradle Plugin",
         y = "Build Import Count",
         title = "Plugin Usage Across Projects",
         caption = "data from gradle.is.idexx.com") +
    darkTheme(0.5) +
    scale_y_continuous(expand=c(0,0))
  return(p)
}

# This Viz will display the average time (secs) it takes to build each Project.
generateBuildTimesChart <- function(builds) {
  p <- ggplot(builds, 
              aes(y = duration, 
                  x = project, 
                  color = project,
                  text = sprintf("<b>Project:</b> %s<br /><b>Duration:</b> %f", project, duration))) + 
    geom_boxplot(alpha = .8, 
                 fill = "#302d2d", 
                 width = 0.85,
                 outlier.alpha = 1,
                 outlier.shape = 2) + 
    geom_jitter(width = 0.1,
                alpha = .3) +
    scale_y_continuous(breaks=seq(0, 10, 1),
                       expand=c(0,0)) +
    coord_flip() +
    darkTheme(0.5) +
    theme(legend.position = "none") +
    labs(y = "Build Time (minutes)",
         x = "Project",
         title = "Project Build Times",
         caption = "data from gradle.is.idexx.com")
  
  return(ggplotly(p, tooltip = "text"))
}

# This is a simple line chart displaying builds over time
generateBuildOverTimeChart <- function(builds) {
  aggData <- count(builds, c("day", "project"))
  aggData$project <- factor(aggData$project)
  p <- ggplot() +
    layer(data = aggData,
          aes(x = day, 
              y = freq, 
              group = project, 
              color = project,
              text = sprintf("<b>Project:</b> %s<br /><b>Builds:</b> %i", project, freq)),
          geom = "line",
          stat = "identity",
          position = "identity") +
    darkTheme(0) +
    labs(y = "Number of Builds",
         x = "Day",
         title = "Builds Per Day By Project",
         caption = "data from gradle.is.idexx.com") +
    theme(legend.title = element_blank()) +
    scale_x_date(date_breaks = "1 days",
                 date_labels = "%b %d",
                 expand = c(0,0)) +
    scale_y_continuous(breaks = seq(0, max(aggData$freq), 10))
  return(ggplotly(p, tooltip = "text"))
}

uiFilter <- function(rawData, uiInput) {
  filteredData <- subset(rawData,
                         rawData$day >= uiInput[1] & rawData$day <= uiInput[2])
  return(filteredData)
}

pluginFilter <- function(pluginData, pluginPrefix = "ALL") {
  if (pluginPrefix == "org.gradle" | pluginPrefix == "com.idexx") {
    return(subset(pluginData, grepl(pluginPrefix, plugin)))
  }
  if (pluginPrefix == "other") {
    return(subset(pluginData, !grepl("org.gradle|com.idexx", plugin)))
  }
  return(pluginData)
}

trimLowFreqencies <- function(data, fieldToCount) {
  countedBuildData <- count(data[[fieldToCount]])
  shavedCountedBuildData <- subset(countedBuildData, freq > 9)
  listOfQualifiedProjects <- shavedCountedBuildData$x
  return(subset(data, data[[fieldToCount]] %in% listOfQualifiedProjects))
}

trimHighFreqencies <- function(data, fieldToCount, trimThreshold) {
  countedBuildData <- count(data[[fieldToCount]])
  shavedCountedBuildData <- subset(countedBuildData, freq <= trimThreshold)
  listOfQualifiedProjects <- shavedCountedBuildData$x
  return(subset(data, data[[fieldToCount]] %in% listOfQualifiedProjects))
}

maxPluginCount <- function(data) {
  countedData <- count(data$plugin)
  return(max(countedData$freq))
  
}

perDayTextOutput <- function(timeInput) {
  return(sprintf(
    "This is a chart displaying the number of project builds per day from: %s to %s", timeInput[1], timeInput[2]))
}

buildTimesTextOutput <- function(timeInput) {
  return(sprintf(
    "This is a chart displaying project build time data from: %s to %s", timeInput[1], timeInput[2]))
}

pluginUsageTextOutput <- function(timeInput) {
  return(sprintf(
    "This is a chart displaying project plugin usage data from: %s to %s", timeInput[1], timeInput[2]))
}



