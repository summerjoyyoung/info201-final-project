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
    artist.to.graph(input$artist.name)
  })
  
  # Mary Elizabeth's File
  output$top.50.graph <- renderPlotly({
    plot_ly(flat.playlist, x = ~track.name, y = ~track.popularity, type = "scatter", hoverinfo = "text",
                   text = ~paste("Song: ", unlist(track.name), "</br> Artist: ", as.list(track.artist.name), 
                                 "</br> Popularity: ", unlist(track.popularity), sep = "")) %>%  
             layout(xaxis = list(showticklabels = FALSE, title = "Your Songs"), 
                    yaxis = list(title = "Popularity"),
                    title = "The Popularity of the Current Top 50 Songs on Spotify")
  })

})
