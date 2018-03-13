source('manipulateData.R')

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
    darkTheme(0.5, 'black') +
    theme(plot.background = element_rect(fill = 'white'),
          axis.text.y = element_text(size = 11)) +
    scale_y_continuous(expand=c(0,0)) +
    scale_fill_manual(values = customPlotColors) +
    scale_color_manual(values = customPlotColors)
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
         caption = "data from gradle.is.idexx.com") +
    scale_color_manual(values = customPlotColors)
  
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
    layer(data = aggData,
          aes(x = day, 
              y = freq, 
              group = project, 
              color = project,
              text = sprintf("<b>Project:</b> %s<br /><b>Builds:</b> %i", project, freq)),
          geom = "point",
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
    scale_y_continuous(breaks = seq(0, max(aggData$freq), 10)) +
    scale_color_manual(values = customPlotColors)
  return(ggplotly(p, tooltip = "text"))
}

# Custom theme for the charts to fit well with Dashboard/UI
darkTheme <- function(titleHAdjust = 0, defaultText = 'white') {
  t <- theme(plot.background = element_rect(fill = '#302d2d', 
                                            color = '#8e8d8d'),
             panel.background = element_rect( fill = '#3d3a3a',
                                              color = '#777777'),
             panel.grid.major = element_line(color = '#660b0b'),
             panel.grid.minor = element_blank(),
             panel.border = element_rect(color = defaultText,
                                         fill = NA,
                                         size = 1.5),
             axis.text.x = element_text(color = defaultText),
             axis.text.y = element_text(color = defaultText),
             axis.title.x = element_text(color = defaultText, 
                                         face = 'bold'),
             axis.title.y = element_text(color = defaultText, 
                                         face = 'bold'),
             plot.caption = element_text(color = defaultText,
                                         size = 10,
                                         face = 'italic'),
             plot.title = element_text(color = defaultText, 
                                       face = 'bold',
                                       size = 16,
                                       hjust = titleHAdjust),
             legend.title = element_text(color = 'white'),
             legend.text = element_text(color = 'white'),
             legend.background = element_rect(fill = '#302d2d'))
  return(t)
}

customPlotColors <- c(
  '#26ff16',
  '#fbff16',
  '#ffa116',
  '#ff1616',
  '#16ff77',
  '#16ffe3',
  '#16c4ff',
  '#1654ff',
  '#6f16ff',
  '#d416ff',
  '#ff16ad',
  '#ff1654',
  '#e6ffc1',
  '#ffeec1',
  '#c1ffee',
  '#c1d5ff',
  '#f3c1ff',
  '#ffc1e2',
  '#ffc1c1',
  '#dbdbdb',
  '#fffcfc'
)
