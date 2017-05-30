# This file has 4 function. Function 1-3 are basically summed up in function #4
# Function 4 is the main function that was designed: artists.top.ten.frame

library(jsonlite)
library(httr)
library(dplyr)

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
frame.top.ten <- function(ID) {
  artist.get.url <- paste0("https://api.spotify.com", "/v1/artists/", ID, "/top-tracks?country=US")
  response.artist <- GET(artist.get.url, token.spotify)
  artist.results <- fromJSON(toJSON(content(response.artist)))
  Popularity <- c()
  Song <- c()
  Preview <- c()
  for (i in 1:10) {
    Popularity <- c(Popularity, artist.results$tracks$popularity[[i]])
    Song <- c(Song, artist.results$tracks$name[[i]])
    Preview <- c(Preview, artist.results$tracks$preview_url[[i]])
  }
  top.ten.data.frame <- data.frame(Popularity, Song, Preview)
  return(top.ten.data.frame)
}


# In this function, you search for an artist and it gives you a data frame of information
artists.top.ten.frame <- function(artist.name.search) {
  # search for artist
  if (grepl(" ", artist.name.search)) {
    name.of.artist <- gsub(" ", "+", artist.name.search)
  }
  url.search.name <- paste0("https://api.spotify.com", "/v1/search?q=", artist.name.search, "&type=artist")
  response <- GET(url.search.name, token.spotify)
  search.results <- fromJSON(toJSON(content(response)))
  name.artist <- search.results$artists$items$name[[1]]
  id <- search.results$artists$items$id[[1]]
  follow <- search.results$artists$items$followers$total[[1]]
  pop <- search.results$artists$items$popularity[[1]]
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
  for (i in 1:10) {
    Name <- c(Name, name.artist)
    Popularity <- c(Popularity, artist.results$tracks$popularity[[i]])
    Song <- c(Song, artist.results$tracks$name[[i]])
    Album <- c(Album, artist.results$tracks$album$name[[i]])
    Preview <- c(Preview, artist.results$tracks$preview_url[[i]])
    Followers <- c(Followers, follow)
    Artist.Popularity <- c(Artist.Popularity, pop)
    Big.Image <- c(Big.Image, artist.results$tracks$album$images[[1]]$url[[1]])
    Medium.Image <- c(Medium.Image, artist.results$tracks$album$images[[1]]$url[[2]])
    Small.Image <- c(Small.Image, artist.results$tracks$album$images[[1]]$url[[3]])
  }
  top.ten.data.frame <- data.frame(Name, Artist.Popularity, Song, Popularity, Album, Preview, Followers, Big.Image, Medium.Image, Small.Image)
  return(top.ten.data.frame)
}



# Testing below

artists.top.ten.frame("drake")
View(artists.top.ten.frame("drake"))




# ------------------------------ hard code and testing is below----------------------------------------------
# note that everything is a bit messy here

artist.name <- "drake"

search.url <- paste0("https://api.spotify.com", "/v1/search?q=", artist.name, "&type=artist")

get.data <- GET(search.url, token.spotify)

testing <- fromJSON(toJSON(content(get.data)))
testing$artists$items$followers
sort.testing <- testing$artists$items$id
#hard coded for drake's id
sort.testing[[1]]
testing$artists$items$name[[1]]
# followers
testing$artists$items$followers$total[[1]]
# popularity
testing$artists$items$popularity[[1]]
# drake's id = 3TVXtAsR1Inumwj472S9r4

# example url: https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF
drake.id <- "3TVXtAsR1Inumwj472S9r4"
get.url <- paste0("https://api.spotify.com", "/v1/artists/", drake.id, "/top-tracks?country=US")
get.drake <- GET(get.url, token.spotify)
blah <- fromJSON(toJSON(content(get.drake)))
# drakes results, you can mess around with this using "$" to see what the data contains
blah$tracks$popularity[[1]]
blah$tracks$name[[1]]

# this is the data frame for the top 10 songs
Popularity <- c()
Song <- c()

for (i in 1:10) {
  # strtoi function converts strings into integers
  Popularity <- c(Popularity, strtoi(blah$tracks$popularity[[i]], base = 0L))
  Song <- c(Song, blah$tracks$name[[i]])
}
#strtoi(x, base = 0L)
# string as factors? (removed)
testing.data.frame <- data.frame(Popularity, Song)
filter(testing.data.frame, Popularity == max(Popularity))
testing.data.frame
# album name
blah$tracks$album$name[[1]]
# artist name
blah$tracks$artists[[1]]$name
# hyperlink reference...A link to the Web API endpoint providing full details of the artist. 
blah$tracks$href
# preview of the song
blah$tracks$preview_url[[1]]
# 
#blah$tracks$uri
# images for the track
blah$tracks$album$images[[1]]$url[[1]] # 650 x 650 pixels
blah$tracks$album$images[[1]]$height[[1]] # height 650
blah$tracks$album$images[[1]]$width[[1]] # width 650
blah$tracks$album$images[[1]]$url[[2]] # 300 x 300 pixels
blah$tracks$album$images[[1]]$height[[2]] # height 650
blah$tracks$album$images[[1]]$width[[2]] # width 650
blah$tracks$album$images[[1]]$url[[3]] # 64 x 64 pixels
blah$tracks$album$images[[1]]$height[[3]] # height 650
blah$tracks$album$images[[1]]$width[[3]] # width

blah$tracks
