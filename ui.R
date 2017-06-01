library(shiny)
library(plotly)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id", '1295238919'), 
      textInput('playlist.id', "Enter the playlist id", '37i9dQZF1DXcBWIGoYBM5M'),
      textInput('artist.name', "Enter the name of an artist to their top songs", 'david bowie')
    ),
    mainPanel(
      tabsetPanel(
         tabPanel("Aislinn's Panel",
                 # img(src = 'test.png', align = "right"),
                  h4("Please be patient, it takes about 20 seconds to generate the graph"),
                  plotlyOutput('aislinns.plot'),
                  textOutput('aislinns.value')
                  ),
         tabPanel("Joy's Panel", 
                  plotlyOutput('joys.plot')
                  ),
         tabPanel("Amitesh's Panel", 
                  tableOutput('amitesh.data')
                  )
      )
      
    )
  )
))