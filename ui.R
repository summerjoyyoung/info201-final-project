library(shiny)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput('user.id', "Enter the user id")
    ),
    mainPanel(
      plotlyOutput('value')
    )
  )
))