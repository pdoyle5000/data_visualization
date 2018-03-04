library(shiny)

shinyUI(fluidPage(

  titlePanel("King County WA Housing Prices Per Year Built",
             windowTitle = "King County Home Price Metrics"),

  sidebarLayout(
     sidebarPanel(width = 3,
      selectInput(
        inputId = "timeScale",
        label = "Select a time scale",
        choices=c("Years" = "year_built",
                  "Decades" = "decade_built"),
        selected=c("Years" = "year_built")
      ),
      selectInput(
        inputId = "zip",
        label = "Choose a zipcode: ",
        choices=dataToAgg$zipcode),
      sliderInput(inputId = "timeSlider",
                  label = "Select a time range",
                  sep = "",
                  min = min(dataToAgg$year_built),
                  max = max(dataToAgg$year_built),
                  value = c(1900, 2015))
     ),
    mainPanel(width = 9,
      tabsetPanel(
        tabPanel("Average Prices Over Time", plotOutput("distPlot", height = 600), height = 700, width = "95%"),
        tabPanel("Price Over Space", plotOutput("mapPlot",height = 600), height = 700, width = "95%"),
        tabPanel("Price Per sq.ft.", plotOutput("linePlot",height = 600), height = 700, width = "95%")
      )
    )
  )
))
