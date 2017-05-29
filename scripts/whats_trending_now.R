library(devtools)
library(jsonlite)
library(httr)
library(dplyr)

#This is all the stuff spotify needs to know before you start
spotifyEndpoint <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", "https://accounts.spotify.com/api/token")
spotifyApp <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
spotifyToken <- oauth2.0_token(spotifyEndpoint, spotifyApp)

base.uri <- 'https://api.spotify.com'

# gets the top playlists on spotify
category.id <- "toplists"
category.playlist.uri <- paste0(base.uri, "/v1/browse/categories/", category.id, "/playlists", "?country=US")
category.playlist.response <- GET(category.playlist.uri, spotifyToken)
category.playlist.body <- content(category.playlist.response, "text")
category.playlist.results <- fromJSON(category.playlist.body)
category.playlist <- category.playlist.results$playlists$items

spotifyUser <- "1279377203"
spotifyPlaylist <- "37i9dQZEVXbLRQDuF5jeBp"

uri <- paste0(base.uri, "/v1/users/", spotifyUser, "/playlists/", spotifyPlaylist, "/tracks", "?country=US")
response <- GET(uri, spotifyToken)
body <- content(response, "text")
results <- fromJSON(body)


# gets a list of spotifies categories for playlists
category.response <- GET("https://api.spotify.com/v1/browse/categories", spotifyToken)
category.body <- content(category.response, "text")
category.results <- fromJSON(category.body)
category <- category.results$categories$items

GetApi <- function(base, resource, query.params) {
  uri <- paste0(base.uri, resource)
  response <- GET(uri, query = query.params)
  body <- content(response, "text")
  results <- fromJSON(body)
  return(results)
}

# artist search
my.artist <- GetApi(base.uri, "/v1/search", list(type = "artist", q = "bowie"))
my.artist <- my.artist$artists$items

# gets the artists top tracks
spotify.artist.id <- '0oSGxfWSnnOXhD2fKuz2Gy' # David Bowie
# top.tracks.url <- paste0(base.uri, "/v1/artists/", spotify.artist.id, "/top-tracks")
# top.tracks.response <- GET(top.tracks.url, query = list(country = "US"))
# top.tracks.body <- content(top.tracks.response, "text")
# top.tracks.results <- fromJSON(top.tracks.body)
artist.top.tracks <- GetApi(base.uri, paste0("/v1/artists/", spotify.artist.id, "/top-tracks"), list(country = "US"))
artist.top.tracks <- artist.top.tracks$tracks



