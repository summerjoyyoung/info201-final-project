library(dplyr)

source('./scripts/UserProfile.R')

shinyServer(function(input, output) {
  output$value <- renderPlotly({
    return(CreateGraph({input$user.id}))
  })
})
