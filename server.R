library(dplyr)

source('./scripts/UserProfile.R')

shinyServer(function(input, output) {
  output$plot.value <- renderPlotly({
    return(CreateGraph({input$user.id}))
  })
  output$value <- renderText({GetDuration(input$user.id)})
 
   output$top.50 <- renderPlotly({
    return(plot_ly(official.playlist, x = ~track.name, y = ~track.popularity, type = "scatter", hoverinfo = "text",
                   text = ~paste("Song: ", unlist(track.name), "</br> Artist: ", track.album.artists, 
                                 "</br> Popularity: ", unlist(track.popularity), sep = "")) %>%  
             layout(xaxis = list(showticklabels = FALSE, title = "Your Songs"), 
                    yaxis = list(title = "Popularity"),
                    title = "The Popularity of the Current Top 50 Songs on Spotify"))})
  
})
