library(shiny)
library(plotly)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id", "1295238919"), 
      textInput('playlist.id', "Enter the playlist id"),
      textInput('artist.name', "Enter the name of an artist to their top songs")
    ),
    mainPanel(
      tabsetPanel(
         tabPanel("Aislinn's Panel",
                  h4("Please be patient, it takes about 20 seconds to generate the graph"),
                  plotlyOutput('aislinns.plot'),
                  textOutput('aislinns.value')
                  ),
         tabPanel("Joy's Panel", 
                  plotlyOutput('joys.plot')
                  ),
         tabPanel("Amitesh's Panel", 
                  plotlyOutput('amitesh.data')
                  ),
         tabPanel("Mary Elizabeth's Panel",
                  plotlyOutput('top.50.graph')
                  )
      )
      
    )
  )
))