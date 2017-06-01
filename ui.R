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
                  p("Trendy Tunes was designed by 4 four students who attend the University of Washington:
                     Amitesh Kataria, Joy Phillips, Aislinn Jeske, and Mary Elizabeth Ward. This application
                     was built using the Spotify API using the R programming language. This is web address 
                     for to the API https://api.spotify.com."),
                  br(),
                  img(src = "rstudio.png", width = "200px", height = "200px"),
                  img(src = "spotify_logo.png", width = "434px", height = "130px"),
                  br(),
                  br(),
                  p("Each tab contains a different feature using the Spotify API, and 
                     each feature provides a description of what it does."),
                  h3("Our developers"),
                  p("Amitesh Kataria Joy Phillips, Mary Elizabeth Ward, and Aislinn Jeske"),
                  img(src = "amitesh.jpg", width = "212px", height = "280px"), #424×560
                  
                  img(src = "joy.jpg", width = "212px", height = "280px"),
                  
                  img(src = "mary.jpg", width = "212px", height = "280px"),
                  
                  img(src = "aislinn.jpg", width = "250px", height = "280px")
                  ),
                 
         tabPanel("User's Music",
                  h2("Please be patient, it takes about 20 seconds to generate the graph"),
                  h4("This graph shows all the user's songs from their public playlists and graphs them based on Spotify's built in popularity feature."),
                  h4("Spotify gives each song a popularity rating based on how many people have listened to it and how recently. An older song that isn't listened to as often will have a lower rating than a popular song that came out last week."),
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
                  h4("This graph shows the 50 most popular songs on Spotify right now, featured on Spotify's playlist \"Today's Top Hits\". The x-axis features the top songs from 1-50 and the y-axis is the popularity of each song."),
                  plotlyOutput('top.50.graph')
                  )
      )
    )
  )
))