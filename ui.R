library(shiny)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id", '1295238919')
    ),
    mainPanel(
      tabsetPanel(
      #img(src = 'test.png', align = "right"),
        tabPanel(h4("Please be patient, it takes about 20 seconds to generate the graph"), 
                 # Change this to say the title of the chart and add this statement somewhere else
                plotlyOutput('plot.value'),
                textOutput("value")
        ),
        tabPanel(h4("Top 50 Ranking Graph"),
                 plotlyOutput('top.50'))
      )
    )
  )
))