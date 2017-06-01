library(shiny)
library(plotly)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id", "1295238919"), 
      textInput('playlist.id', "Enter the playlist id", "37i9dQZF1DX4JAvHpjipBk"),
      selectInput(inputId = "y",
                  label = "Y-Axis",
                  choices = c("danceability", "energy", "key", "loudness", "mode", "speechiness", "acousticness", "instrumentalness", "liveness", "valence", "tempo", "duration_ms"),
                  selected = "danceability"),
      textInput('artist.name', "Enter the name of an artist to get their top 10 songs", "kodak black")
    ),
    mainPanel(
      tabsetPanel(position = "below",
         tabPanel("About Us",
                  h1("                        Trendy Tunes"),
                  h4("Trendy Tunes was designed by 4 four students who attend the University of Washington:
                     Amitesh Kataria, Joy Phillips, Aislinn Jeske, and Mary Elizabeth Ward. This application
                     was built using the Spotify API using the R programming language."),
                  br(),
                  img(src = "https://www.rstudio.com/wp-content/uploads/2014/06/RStudio-Ball.png", width = "200px", height = "200px"),
                  img(src = "https://spotifyblogcom.files.wordpress.com/2015/02/spotify_logo_cmyk_black1.png", width = "434px", height = "130px"),
                  h4("Each tab contains a different feature using the Spotify API, and 
                     each feature provides a description of what it does.")
                  ),
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
                  h6("This graph shows the top 10 songs for the artist you have searched. It takes the ranking of the artists"),
                  h6("top 10 song based on popularity (0 - 100) and graphs it. It also shows the artist name, along with the"),
                  h6("name of the song. Hover over each point for more information."),
                  br(),
                  em("Please give it 5 to 10 seconds to load the graph"),
                  plotlyOutput('amitesh.data'),
                  h6("Remember to change the artist name by using the widget on the side.")
                  
                  ),
         tabPanel("Top Songs on Spotify",
                  plotlyOutput('top.50.graph')
                  )
      )
    )
  )
))