library(shiny)
library(dplyr)
library(plotly)
source('./scripts/UserProfile.R') # Aislinn's File
source('./scripts/audio_features.R') # Joy's File
source('./scripts/top_artists.R') # Amitesh's File
source('./scripts/top_listened.R') # Mary's File



shinyServer(function(input, output) {
  # Aislinn's File
  output$aislinns.plot <- renderPlotly({
    CreateGraph({input$user.id})
  })
  output$aislinns.value <- renderText({GetDuration(input$user.id)})
  
  # Joy's File
  output$joys.plot <- renderPlotly({
    JoysGraph(input$playlist.id)
  })

  # Amitesh's File
  output$amitesh.data <- renderPlotly({
    artists.top.ten.frame(input$artist.name)
  })
  
  # Mary Elizabeth's File
  output$top.50.graph <- renderPlotly({
    return(plot_ly(official.playlist, x = ~track.name, y = ~track.popularity, 
                    color = ~track.explicit,
                    type = "scatter", hoverinfo = "text", 
                    text = ~paste("Song: ", unlist(track.name), "</br> Artist: ", track.album.artists, 
                                  "</br> Popularity: ", unlist(track.popularity), sep = "")) %>%  
              layout(xaxis = list(showticklabels = FALSE, title = "Ranking"), 
                     yaxis = list(title = "Popularity"),
                     title = "Popularity of the Current Top 50 Songs on Spotify"))
  })

})
