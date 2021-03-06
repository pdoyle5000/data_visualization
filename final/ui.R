shinyUI(
  fluidPage(theme = shinytheme("darkly"),
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
               style = "padding: 10px;")  
      )
    ),
    fluidRow(
      column(12,
             tabsetPanel(
               tabPanel(
                 HTML("<b>Daily Builds By Project</b>"),
                 fluidRow(
                   column(10,
                          plotlyOutput("perDayPlot", height = 680)),
                   column(2,
                          textOutput("perDayText")),
                 height = 800,
                 width = '98%')),
               tabPanel(
                 HTML("<b>Build Durations By Project</b>"),
                 fluidRow(
                   column(10,
                          plotlyOutput("buildTimePlot", height = 680)),
                   column(2,
                          textOutput("buildText")),
                 height = 800,
                 width = '98%')),
               tabPanel(
                 HTML("<b>Plugin Usage Across Projects</b>"),
                 fluidRow(
                   column(10,
                          plotOutput("pluginPlot", height = 750)),
                   column(2,
                          selectInput(inputId = "pluginGroup",
                                      label = "Plugin Company",
                                      choices = c(
                                                  "Idexx" = "com.idexx",
                                                  "Gradle" = "org.gradle",
                                                  "Other" = "other")),
                          sliderInput(inputId = "buildCount",
                                      label = "Max Build Count",
                                      min = 0,
                                      max = pluginCount,
                                      value = pluginCount),
                          textOutput("pluginText")),
                   height = 800,
                   width = '98%'))
               )
        )
  )
))