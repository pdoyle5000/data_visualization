shinyServer(
  function(input, output) {
    output$perDayPlot <- renderPlotly({
      withProgress(message = 'Generating Build Count Plot', value = 0, {
        cleanBuildData <- trimLowFreqencies(buildData, "project")
        generateBuildOverTimeChart(
          uiFilter(cleanBuildData, input$timeSlider))
      })
    })
    
    output$pluginPlot <- renderPlot({
      withProgress(message = 'Generating Plugin Usage Plot', value = 0, {
        cleanPluginsListing <- trimLowFreqencies(pluginsListing, "Projects")
        cleanPluginsListing <- trimHighFreqencies(pluginsListing, "plugin", input$buildCount)
        groupFilteredPlugins <- pluginFilter(cleanPluginsListing, input$pluginGroup)
        generatePluginChart(
          uiFilter(groupFilteredPlugins, input$timeSlider))
      })
    })

    output$buildTimePlot <- renderPlotly({
      withProgress(message = 'Generating Build Time Plot', value = 0, {
        generateBuildTimesChart( # Builds that take longer than an hour are errors.
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