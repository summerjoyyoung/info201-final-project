library(dplyr)

shinyServer(function(input, output) {
  output$value <- renderText({input$user.id})
})
