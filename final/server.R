shinyServer(
  function(input, output) {
    output$perDayPlot <- renderPlotly({
      withProgress(message = 'Generating Build Count Plot', value = 0, {
        generateBuildOverTimeChart(
          uiFilter(buildData, input$timeSlider))
      })
    })
    
    output$pluginPlot <- renderPlot({
      withProgress(message = 'Generating Plugin Usage Plot', value = 0, {
        generatePluginChart(
          uiFilter(pluginsListing, input$timeSlider))
      })
    })

    output$buildTimePlot <- renderPlotly({
      withProgress(message = 'Generating Build Time Plot', value = 0, {
        generateBuildTimesChart(
          uiFilter(subset(buildData, duration < 60), input$timeSlider))
      })
      # Builds that take longer than an hour are errors.
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