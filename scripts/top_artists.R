# load necessary library's
library(jsonlite)
library(httr)
library(dplyr)
library(plotly)


# API information

endpoint.spotify <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", "https://accounts.spotify.com/api/token")
app.spotify <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
token.spotify <- oauth2.0_token(endpoint.spotify, app.spotify)

# search for artist
# function that takes artist name as input and outputs the artists ID
find.artist.id <- function(name.of.artist) {
  if (grepl(" ", name.of.artist)) {
    name.of.artist <- gsub(" ", "+", name.of.artist)
  }
  url.search.name <- paste0("https://api.spotify.com", "/v1/search?q=", name.of.artist, "&type=artist")
  response <- GET(url.search.name, token.spotify)
  search.results <- fromJSON(toJSON(content(response)))
  ids <- search.results$artists$items$id
  return(ids[[1]])
}
#top.10.songs(find.artist.id("kendrick lamar"))
# take in artist ID and give the top songs as a list
# top 10 songs function
top.10.songs <- function(artists.id) {
  artist.get.url <- paste0("https://api.spotify.com", "/v1/artists/", artists.id, "/top-tracks?country=US")
  response.artist <- GET(artist.get.url, token.spotify)
  artist.results <- fromJSON(toJSON(content(response.artist)))
  top.ten <- artist.results$tracks$name
  return(top.ten)
}

# take in artist ID and give the top songs with popularity
# top 10 data frame function
# minimal amount of data
frame.top.ten <- function(ID) {
  artist.get.url <- paste0("https://api.spotify.com", "/v1/artists/", ID, "/top-tracks?country=US")
  response.artist <- GET(artist.get.url, token.spotify)
  artist.results <- fromJSON(toJSON(content(response.artist)))
  Popularity <- c()
  Song <- c()
  Preview <- c()
  for (i in 1:length(artist.results$tracks$name)) {
    Popularity <- c(Popularity, artist.results$tracks$popularity[[i]])
    Song <- c(Song, artist.results$tracks$name[[i]])
    Preview <- c(Preview, artist.results$tracks$preview_url[[i]])
  }
  top.ten.data.frame <- data.frame(Popularity, Song, Preview)
  return(top.ten.data.frame)
}

# ------------------------------ Important function -------------------------------------------------------------------------------------


# In this function, you search for an artist and it gives you a data frame of information
artists.top.ten.frame <- function(artist.name.search) {
  # if search with two or more strings
  if (grepl(" ", artist.name.search)) {
    artist.name.search <- gsub(" ", "+", artist.name.search)
  } 
  #search for artist
  url.search.name <- paste0("https://api.spotify.com", "/v1/search?q=", artist.name.search, "&type=artist")
  response <- GET(url.search.name, token.spotify)
  search.results <- fromJSON(toJSON(content(response)))
  name.artist <- search.results$artists$items$name[[1]]
  id <- search.results$artists$items$id[[1]]
  follow <- search.results$artists$items$followers$total[[1]]
  popular <- search.results$artists$items$popularity[[1]]
  artist.get.url <- paste0("https://api.spotify.com", "/v1/artists/", id, "/top-tracks?country=US")
  response.artist <- GET(artist.get.url, token.spotify)
  artist.results <- fromJSON(toJSON(content(response.artist)))
  Name <- c() # name of artist
  Popularity <- c() # for individual song
  Song <- c() # name of song
  Preview <- c() # hyperlink to preview of song
  Followers <- c() # individual artists follower count
  Artist.Popularity <- c() # individual popularity of artist
  Album <- c() # album name for the that individual song
  Big.Image <- c() # 650x650 pixels album image
  Medium.Image <- c() # 300x300 pixels album image
  Small.Image <- c() # 64x64 pixels album image
  # the for loop is set up incase an artist doesn't have a top ten
  for (i in 1:length(artist.results$tracks$name)) {
    Name <- c(Name, name.artist)
    Popularity <- c(Popularity, artist.results$tracks$popularity[[i]])
    Song <- c(Song, artist.results$tracks$name[[i]])
    Album <- c(Album, artist.results$tracks$album$name[[i]])
    #Preview <- c(Preview, artist.results$tracks$preview_url[[i]])
    Followers <- c(Followers, follow)
    Artist.Popularity <- c(Artist.Popularity, popular)
    #Big.Image <- c(Big.Image, artist.results$tracks$album$images[[1]]$url[[1]])
    #Medium.Image <- c(Medium.Image, artist.results$tracks$album$images[[1]]$url[[2]])
    #Small.Image <- c(Small.Image, artist.results$tracks$album$images[[1]]$url[[3]])
  }
  #top.ten.data.frame <- data.frame(Name, Artist.Popularity, Song, Popularity, Album, Preview, Followers, Big.Image, Medium.Image, Small.Image)
  top.ten.data.frame <- data.frame(Name, Artist.Popularity, Song, Popularity, Album, Followers)
  while (nrow(top.ten.data.frame) < 10) {
    new.row = data.frame(Name=name.artist, Artist.Popularity=popular, Song="none", Popularity=0, Album="none", Followers=0)
    top.ten.data.frame <- rbind(top.ten.data.frame, new.row)
  }
  return(top.ten.data.frame)
}




# # Testing below
# artists.top.ten.frame("future")
# artists.top.ten.frame("taylor swift")
# drake.frame <- artists.top.ten.frame("drake")
# taylor.frame <- artists.top.ten.frame("taylor swift")
# View(artists.top.ten.frame("drake"))

# ------------------------------ The graph's-------------------------------------------------------------------------------------

# line graph, that takes in the data frame and outputs the graph
# got graph from here: https://plot.ly/r/line-and-scatter/

# this creates the single graph
p.graph <- function(data.input) {
  artist <- data.input$Name[1]
  
  p <- plot_ly(data.input, x = ~1:nrow(data.input), y = ~Popularity, type = 'scatter', mode = 'lines+markers', marker = list(size = 8), hoverinfo = "text", text = ~paste0("Artist: ", artist, "\nSong: ", data.input$Song, "\nPopularity Rank: ", data.input$Popularity)) %>%
    layout(title = "Popularity of Top Songs", xaxis = list(title = "Each Song", zeroline = TRUE, dtick = 1 ), yaxis = list(title = "Popularity Ranking", zeroline = TRUE, range = c(0,100))) %>%
    rangeslider(start = .9, end = 10.1)
  return(p) 
}

# artists.top.ten.frame("drake")
# # test graph above
# p.graph(drake.frame)
# p.graph(taylor.frame)

# ------------------------------ Single artist graph-------------------------------------------------------------------------------------

# single artist graph
artist.to.graph <- function(artist.name) {
  artist.frame <- artists.top.ten.frame(artist.name)
  return(p.graph(artist.frame))
}

# artist.to.graph("drake")
# 

# ------------------------------ Two artist graph-------------------------------------------------------------------------------------

# only compare two artists
two.artists.to.graph <- function(artist.list) {
  data.input <- artists.top.ten.frame(artist.list[1])
  data.input.two <- artists.top.ten.frame(artist.list[2])
  
  p <- plot_ly(data.input, x = ~1:nrow(data.input), y = ~Popularity,name = data.input$Name[1], type = 'scatter', mode = 'lines+markers', marker = list(size = 8), hoverinfo = "text", text = ~paste0("Artist: ", data.input$Name[1], "\nSong: ", data.input$Song, "\nPopularity Rank: ", data.input$Popularity)) %>%
    add_trace(y = ~data.input.two$Popularity,x = ~1:nrow(data.input.two), name = data.input.two$Name[1], text = ~paste0("Artist: ", data.input.two$Name[1], "\nSong: ", data.input.two$Song, "\nPopularity Rank: ", data.input.two$Popularity)) %>%
    layout(title = "Popularity of Top Songs", xaxis = list(title = "Each Song", zeroline = TRUE, dtick = 1 ), yaxis = list(title = "Popularity Ranking", zeroline = TRUE, range = c(0,100))) %>%
    rangeslider(start = .9, end = 10.1)
  return(p)
}

# ------------------------------ Three artist graph-------------------------------------------------------------------------------------

three.artists.to.graph <- function(artist.list) {
  data.input <- artists.top.ten.frame(artist.list[1])
  data.input.two <- artists.top.ten.frame(artist.list[2])
  data.input.three <- artists.top.ten.frame(artist.list[3])
  
  p <- plot_ly(data.input, x = ~1:nrow(data.input), y = ~Popularity,name = data.input$Name[1], type = 'scatter', mode = 'lines+markers', marker = list(size = 8), hoverinfo = "text", text = ~paste0("Artist: ", data.input$Name[1], "\nSong: ", data.input$Song, "\nPopularity Rank: ", data.input$Popularity)) %>%
    add_trace(y = ~data.input.two$Popularity,x = ~1:nrow(data.input.two), name = data.input.two$Name[1], text = ~paste0("Artist: ", data.input.two$Name[1], "\nSong: ", data.input.two$Song, "\nPopularity Rank: ", data.input.two$Popularity)) %>%
    add_trace(y = ~data.input.three$Popularity,x = ~1:nrow(data.input.three), name = data.input.three$Name[1], text = ~paste0("Artist: ", data.input.three$Name[1], "\nSong: ", data.input.three$Song, "\nPopularity Rank: ", data.input.three$Popularity)) %>%
    layout(title = "Popularity of Top Songs", xaxis = list(title = "Each Song", zeroline = TRUE, dtick = 1 ), yaxis = list(title = "Popularity Ranking", zeroline = TRUE, range = c(0,100))) %>%
    rangeslider(start = .9, end = 10.1)
  return(p)
}

# ------------------------------ Four artist graph-------------------------------------------------------------------------------------

four.artists.to.graph <- function(artist.list) {
  data.input <- artists.top.ten.frame(artist.list[1])
  data.input.two <- artists.top.ten.frame(artist.list[2])
  data.input.three <- artists.top.ten.frame(artist.list[3])
  data.input.four <- artists.top.ten.frame(artist.list[4])
  p <- plot_ly(data.input, x = ~1:nrow(data.input), y = ~Popularity,name = data.input$Name[1], type = 'scatter', mode = 'lines+markers', marker = list(size = 8), hoverinfo = "text", text = ~paste0("Artist: ", data.input$Name[1], "\nSong: ", data.input$Song, "\nPopularity Rank: ", data.input$Popularity)) %>%
    add_trace(y = ~data.input.two$Popularity,x = ~1:nrow(data.input.two), name = data.input.two$Name[1], text = ~paste0("Artist: ", data.input.two$Name[1], "\nSong: ", data.input.two$Song, "\nPopularity Rank: ", data.input.two$Popularity)) %>%
    add_trace(y = ~data.input.three$Popularity,x = ~1:nrow(data.input.three), name = data.input.three$Name[1], text = ~paste0("Artist: ", data.input.three$Name[1], "\nSong: ", data.input.three$Song, "\nPopularity Rank: ", data.input.three$Popularity)) %>%
    add_trace(y = ~data.input.four$Popularity,x = ~1:nrow(data.input.four), name = data.input.four$Name[1], text = ~paste0("Artist: ", data.input.four$Name[1], "\nSong: ", data.input.four$Song, "\nPopularity Rank: ", data.input.four$Popularity)) %>%
    layout(title = "Popularity of Top Songs", xaxis = list(title = "Each Song", zeroline = TRUE, dtick = 1 ), yaxis = list(title = "Popularity Ranking", zeroline = TRUE, range = c(0,100))) %>%
    rangeslider(start = .9, end = 10.1)
  return(p)
}

# ------------------------------ Five artist graph-------------------------------------------------------------------------------------

five.artists.to.graph <- function(artist.list) {
  data.input <- artists.top.ten.frame(artist.list[1])
  data.input.two <- artists.top.ten.frame(artist.list[2])
  data.input.three <- artists.top.ten.frame(artist.list[3])
  data.input.four <- artists.top.ten.frame(artist.list[4])
  data.input.five <- artists.top.ten.frame(artist.list[5])
  p <- plot_ly(data.input, x = ~1:nrow(data.input), y = ~Popularity,name = data.input$Name[1], type = 'scatter', mode = 'lines+markers', marker = list(size = 8), hoverinfo = "text", text = ~paste0("Artist: ", data.input$Name[1], "\nSong: ", data.input$Song, "\nPopularity Rank: ", data.input$Popularity)) %>%
    add_trace(y = ~data.input.two$Popularity,x = ~1:nrow(data.input.two), name = data.input.two$Name[1], text = ~paste0("Artist: ", data.input.two$Name[1], "\nSong: ", data.input.two$Song, "\nPopularity Rank: ", data.input.two$Popularity)) %>%
    add_trace(y = ~data.input.three$Popularity,x = ~1:nrow(data.input.three), name = data.input.three$Name[1], text = ~paste0("Artist: ", data.input.three$Name[1], "\nSong: ", data.input.three$Song, "\nPopularity Rank: ", data.input.three$Popularity)) %>%
    add_trace(y = ~data.input.four$Popularity,x = ~1:nrow(data.input.four), name = data.input.four$Name[1], text = ~paste0("Artist: ", data.input.four$Name[1], "\nSong: ", data.input.four$Song, "\nPopularity Rank: ", data.input.four$Popularity)) %>%
    add_trace(y = ~data.input.five$Popularity,x = ~1:nrow(data.input.five), name = data.input.five$Name[1], text = ~paste0("Artist: ", data.input.five$Name[1], "\nSong: ", data.input.five$Song, "\nPopularity Rank: ", data.input.five$Popularity)) %>%
    layout(title = "Popularity of Top Songs", xaxis = list(title = "Each Song", zeroline = TRUE, dtick = 1 ), yaxis = list(title = "Popularity Ranking", zeroline = TRUE, range = c(0,100))) %>%
    rangeslider(start = .9, end = 10.1)
  return(p)
}

# test each of the graphs
# artist.to.graph("drake")
# two.artists.to.graph(c("drake", "taylor swift"))
# three.artists.to.graph(c("drake", "rihanna", "taylor swift"))
# four.artists.to.graph(c("drake", "rihanna", "taylor swift", "beyonce"))
# five.artists.to.graph(c("drake", "rihanna", "taylor swift", "beyonce", "lil yachty"))







# ------------------------------ hard code and testing is below------------------------------------------------------------------
# note that everything is a bit messy here

# artist.name <- "drake"
# 
# search.url <- paste0("https://api.spotify.com", "/v1/search?q=", artist.name, "&type=artist")
# 
# get.data <- GET(search.url, token.spotify)
# 
# testing <- fromJSON(toJSON(content(get.data)))
# testing$artists$items$followers
# sort.testing <- testing$artists$items$id
# #hard coded for drake's id
# sort.testing[[1]]
# testing$artists$items$name[[1]]
# # followers
# testing$artists$items$followers$total[[1]]
# # popularity
# testing$artists$items$popularity[[1]]
# # drake's id = 3TVXtAsR1Inumwj472S9r4
# 
# # example url: https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF
# drake.id <- "06HL4z0CvFAxyc27GXpf02"
# get.url <- paste0("https://api.spotify.com", "/v1/artists/", drake.id, "/top-tracks?country=US")
# get.drake <- GET(get.url, token.spotify)
# blah <- fromJSON(toJSON(content(get.drake)))
# length(blah$tracks$name)
# # drakes results, you can mess around with this using "$" to see what the data contains
# blah$tracks$popularity[[1]]
# blah$tracks$name[[1]]
# 
# # this is the data frame for the top 10 songs
# Popularity <- c()
# Song <- c()
# 
# for (i in 1:10) {
#   # strtoi function converts strings into integers
#   Popularity <- c(Popularity, strtoi(blah$tracks$popularity[[i]], base = 0L))
#   Song <- c(Song, blah$tracks$name[[i]])
# }
# #strtoi(x, base = 0L)
# # string as factors? (removed)
# testing.data.frame <- data.frame(Popularity, Song)
# filter(testing.data.frame, Popularity == max(Popularity))
# testing.data.frame
# # album name
# blah$tracks$album$name[[1]]
# # artist name
# blah$tracks$artists[[1]]$name
# # hyperlink reference...A link to the Web API endpoint providing full details of the artist. 
# blah$tracks$href
# # preview of the song
# blah$tracks$preview_url[[1]]
# # 
# #blah$tracks$uri
# # images for the track
# blah$tracks$album$images[[1]]$url[[1]] # 650 x 650 pixels
# blah$tracks$album$images[[1]]$height[[1]] # height 650
# blah$tracks$album$images[[1]]$width[[1]] # width 650
# blah$tracks$album$images[[1]]$url[[2]] # 300 x 300 pixels
# blah$tracks$album$images[[1]]$height[[2]] # height 650
# blah$tracks$album$images[[1]]$width[[2]] # width 650
# blah$tracks$album$images[[1]]$url[[3]] # 64 x 64 pixels
# blah$tracks$album$images[[1]]$height[[3]] # height 650
# blah$tracks$album$images[[1]]$width[[3]] # width
# 
# blah$tracks
