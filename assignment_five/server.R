library(shiny)
library(ggplot2)
library(gridExtra)
source('functions.R')

# Re-renders charts based on user input changes.
shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    dataToView <- filterData(dataToAgg, input$timeScale, input$timeSlider, input$zip)
    drawBarChart(dataToView, input$timeScale)
  })
  
  output$mapPlot <- renderPlot({
    dataToView <- filterData(dataToAgg, input$timeScale, input$timeSlider, input$zip)
    drawCountyMap(dataToView)
  })
  
  output$linePlot <- renderPlot({
    dataToView <- filterData(dataToAgg, input$timeScale, input$timeSlider, input$zip)
    drawLineCharts(dataToView)
  })

})