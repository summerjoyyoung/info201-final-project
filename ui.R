library(shiny)
library(plotly)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id", "1295238919"), 
      textInput('playlist.id', "Enter the playlist id", "37i9dQZF1DX4JAvHpjipBk"),
      textInput('artist.name', "Enter the name of an artist to their top songs", "Jimi Hendrix")
    ),
    mainPanel(
      tabsetPanel(
         tabPanel("User's Music",
                  h4("Please be patient, it takes about 20 seconds to generate the graph"),
                  plotlyOutput('aislinns.plot'),
                  textOutput('aislinns.value')
                  ),
         tabPanel("Songs in a Playlist", 
                  plotlyOutput('joys.plot')
                  ),
         tabPanel("Songs for an Artist", 
                  plotlyOutput('amitesh.data')
                  ),
         tabPanel("Top Songs on Spotify",
                  plotlyOutput('top.50.graph')
                  )
      )
      
    )
  )
))