shinyUI(
  fluidPage(
    titlePanel("Idexx Embedded Development - Gradle Software Builds"),
    fluidRow(
      column(9,
             tabsetPanel(
               tabPanel(
                 HTML("<b>Plugin Usage Per Project</b>"),
                 plotOutput("pluginPlot", height = 650),
                 height = 7000, 
                 width = '98%'),
               tabPanel(
                 "Build Totals Per Day",
                 plotlyOutput("perDayPlot", height = 650),
                 height = 700, 
                 width = '98%'),
               tabPanel(
                 "Project Build Durations",
                 plotlyOutput("buildTimePlot", height = 650),
                 height = 700, 
                 width = '98%')
               )
             ),
      column(3,
             wellPanel(
                sliderInput("obs", "Number of observations:",  
                         min = 1, max = 1000, value = 500)
           )  
     )
  )
))