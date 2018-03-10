shinyServer(
  function(input, output) {
    output$perDayPlot <- renderPlotly({
      generateBuildOverTimeChart(buildData)
    })
    
    output$pluginPlot <- renderPlot({
      generatePluginChart(pluginsListing)
    })

    output$buildTimePlot <- renderPlotly({
      generateBuildTimesChart(subset(buildData, duration < 60))
    })
  }
)