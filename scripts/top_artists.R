library(jsonlite)
library(httr)
library(dplyr)


# API information

endpoint.spotify <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", "https://accounts.spotify.com/api/token")
app.spotify <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
token.spotify <- oauth2.0_token(endpoint.spotify, app.spotify)

# search for artist

# function: artist name input
find.artist.id <- function(name.of.artist) {
  url.search.name <- paste0("https://api.spotify.com", "/v1/search?q=", name.of.artist, "&type=artist")
  response <- GET(url.search.name, token.spotify)
  search.results <- fromJSON(toJSON(content(response)))
  ids <- search.results$artists$items$id
  return(ids[1])
  
}
# end function

# test function
find.artist.id("beyonce")  # id = "6vWDO969PvNqNYHIOW5v0m"

# take in artist ID and give the top songs with popularity

top.10.songs <- function(input.ID) {
  artist.get.url <- paste0("https://api.spotify.com", "/v1/artists/", input.ID, "/top-tracks?country=US")
  response.artist <- GET(artist.get.url, token.spotify)
  artist.results <- fromJSON(toJSON(content(response.artist)))
  top.ten <- artist.results$tracks$name
  return(top.ten)
}

test.artist.id <- find.artist.id("drake")
drake.top.10 <- top.10.songs(test.artist.id)

# ------------------------------ hard code and testing is below----------------------------------------------
# note that everything is a bit messy here

artist.name <- "drake"

search.url <- paste0("https://api.spotify.com", "/v1/search?q=", artist.name, "&type=artist")

get.data <- GET(search.url, token.spotify)

testing <- fromJSON(toJSON(content(get.data)))
testing$artists$items$followers
sort.testing <- testing$artists$items$id
#hard coded for drake's id
sort.testing[1]

# drake's id = 3TVXtAsR1Inumwj472S9r4

# example url: https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF
drake.id <- "3TVXtAsR1Inumwj472S9r4"
get.url <- paste0("https://api.spotify.com", "/v1/artists/", drake.id, "/top-tracks?country=US")
get.drake <- GET(get.url, token.spotify)
blah <- fromJSON(toJSON(content(get.drake)))
# drakes results, you can mess around with this using "$" to see what the data contains
blah$tracks$name
