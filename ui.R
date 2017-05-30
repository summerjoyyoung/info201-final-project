library(shiny)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id", '1295238919')
    ),
    mainPanel(
      #img(src = 'test.png', align = "right"),
      h4("Please be patient, it takes about 20 seconds to generate the graph"),
      plotlyOutput('plot.value'),
      textOutput("value")
    )
  )
))