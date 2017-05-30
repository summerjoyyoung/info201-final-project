library(dplyr)

source('./scripts/UserProfile.R')

shinyServer(function(input, output) {
  output$plot.value <- renderPlotly({
    return(CreateGraph({input$user.id}))
  })
  
  output$value <- renderText({GetDuration(input$user.id)})
})
