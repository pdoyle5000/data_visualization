shinyServer(
  function(input, output) {
    output$perDayPlot <- renderPlotly({
      generateBuildOverTimeChart(
        uiFilter(buildData, input$timeSlider))
    })
    
    output$pluginPlot <- renderPlot({
      filteredPlugins <- uiPluginFilter(pluginsListing, input$pluginTop, input$pluginBottom)
      generatePluginChart(
        uiFilter(filteredPlugins, input$timeSlider))
    })

    output$buildTimePlot <- renderPlotly({
      generateBuildTimesChart(
        uiFilter(subset(buildData, duration < 60), input$timeSlider))
      # Builds that take longer than an hour are errors.
    })
  }
)