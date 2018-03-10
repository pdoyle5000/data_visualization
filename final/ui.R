shinyUI(
  fluidPage(
    titlePanel("Idexx Embedded Development - Gradle Software Builds"),
    fluidRow(
      column(12,
             wellPanel(
               sliderInput(inputId = "timeSlider", 
                           label = "Select Time Range:",
                           min = min(buildData$day),
                           max = max(buildData$day),
                           value = c(min(buildData$day), 
                                     max(buildData$day))),
               style = "padding: 10px;"
             )  
      )
    ),
    fluidRow(
      column(12,
             tabsetPanel(
               tabPanel(
                 HTML("<b>Plugin Usage Per Project</b>"),
                 plotOutput("pluginPlot", height = 680),
                 height = 800, 
                 width = '98%'),
               tabPanel(
                 "Per Day Build Totals",
                 plotlyOutput("perDayPlot", height = 680),
                 height = 800, 
                 width = '98%'),
               tabPanel(
                 "Project Build Durations",
                 plotlyOutput("buildTimePlot", height = 680),
                 height = 800, 
                 width = '98%')
               )
             )
  )
))