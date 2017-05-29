library(shiny)

shinyUI(navbarPage(
  titlePanel("Trendy Tunes"),
  sidebarLayout(
    sidebarPanel(
      textInput("user.id", "Enter the user id"),
      verbatimTextOutput("value")
    ),
    mainPanel(
      h1("Test text")
    )
  )
))