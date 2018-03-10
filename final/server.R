shinyServer(
  function(input, output) {
    output$perDayPlot <- renderPlotly({
      generateBuildOverTimeChart(
        uiFilter(buildData, input$timeSlider))
    })
    
    output$pluginPlot <- renderPlot({
      generatePluginChart(
        uiFilter(pluginsListing, input$timeSlider))
    })

    output$buildTimePlot <- renderPlotly({
      generateBuildTimesChart(
        uiFilter(subset(buildData, duration < 60), input$timeSlider))
      # Builds that take longer than an hour are errors.
    })
  }
)