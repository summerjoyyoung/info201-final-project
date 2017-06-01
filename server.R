library(shiny)
library(dplyr)
library(plotly)
source('./scripts/UserProfile.R') # Aislinn's File
source('./scripts/audio_features.R') # Joy's File
source('./scripts/top_artists.R') # Amitesh's File
# source('./scripts/top_listened.R') # Mary's File



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
})
