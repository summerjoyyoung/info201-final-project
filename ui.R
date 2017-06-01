library(shiny)
library(plotly)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id", "1295238919"), 
      textInput('playlist.id', "Enter the playlist id", "37i9dQZF1DX4JAvHpjipBk"),
      textInput('artist.name', "Enter the name of an artist to get their top 10 songs", "pink")
    ),
    mainPanel(
      tabsetPanel(position = "below",
         tabPanel("User's Music",
                  h4("Please be patient, it takes about 20 seconds to generate the graph"),
                  plotlyOutput('aislinns.plot'),
                  textOutput('aislinns.value')
                  ),
         tabPanel("Songs in a Playlist", 
                  plotlyOutput('joys.plot'),
                  h5("The user can input a playlist key into the playlist id text box. It then takes a moment for the graph to load and for the graph to update and load. On the y axis is the audio feature danceablility with the x axis of track names. This allows the user to view how danceablility vairies between songs in a specific playlist. Hover over the plot points to get more information about the specific song.")
                  ),
         tabPanel("Top 10 Songs for an Artist", 
                  br(),
                  h6("Remember to change the artist name by using the widget on the side"),
                  plotlyOutput('amitesh.data')
                  ),
                  
         tabPanel("Top Songs on Spotify",
                  plotlyOutput('top.50.graph')
                  )
      )
    )
  )
))