shinyServer(
  function(input, output) {
    output$perDayPlot <- renderPlotly({
      withProgress(message = 'Generating Build Count Plot', value = 0, {
        generateBuildOverTimeChart(
          uiFilter(buildData, input$timeSlider))
      })
    })
    
    output$pluginPlot <- renderPlot({
      groupFilteredPlugins <- pluginFilter(pluginsListing, input$pluginGroup)
      withProgress(message = 'Generating Plugin Usage Plot', value = 0, {
        generatePluginChart(
          uiFilter(groupFilteredPlugins, input$timeSlider))
      })
    })

    output$buildTimePlot <- renderPlotly({
      withProgress(message = 'Generating Build Time Plot', value = 0, {
        generateBuildTimesChart( # Builds that take longer than an hour are errors.
          uiFilter(subset(buildData, duration < 60), input$timeSlider))
      })
    })
    
    output$perDayText <- renderText({
      perDayTextOutput(input$timeSlider)
    })
    
    output$pluginText <- renderText({
      pluginUsageTextOutput(input$timeSlider)
    })
    
    output$buildText <- renderText({
      buildTimesTextOutput(input$timeSlider)
    })
  }
)