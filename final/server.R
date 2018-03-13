shinyServer(
  function(input, output) {
    output$perDayPlot <- renderPlotly({
      withProgress(message = 'Generating Build Count Plot', value = 0, {
        cleanBuildData <- trimLowFrequencies(buildData, "project", 10)
        generateBuildOverTimeChart(
          uiFilter(cleanBuildData, input$timeSlider))
      })
    })
    
    output$pluginPlot <- renderPlot({
      withProgress(message = 'Generating Plugin Usage Plot', value = 0, {
        cleanPluginsListing <- trimHighFrequencies(
          trimLowFrequencies(
            pluginsListing, "Projects", 10
          ), "plugin", input$buildCount)
        groupFilteredPlugins <- pluginFilter(cleanPluginsListing, input$pluginGroup)
        generatePluginChart(
          uiFilter(groupFilteredPlugins, input$timeSlider))
      })
    })

    output$buildTimePlot <- renderPlotly({
      withProgress(message = 'Generating Build Time Plot', value = 0, {
        generateBuildTimesChart( # Builds that take longer than ten minutes are errors.
          uiFilter(subset(buildData, duration < 10), input$timeSlider))
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