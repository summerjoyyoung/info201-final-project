library(devtools)
library(jsonlite)
library(httr)
library(dplyr)
library(plotly)
library(RColorBrewer)

#This is all the stuff spotify needs to know before you start
spotifyEndpoint <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", 
                                  "https://accounts.spotify.com/api/token")
spotifyApp <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', 
                        '5094f0bd6d4b4a368a990909d2a15acd')
spotifyToken <- oauth2.0_token(spotifyEndpoint, spotifyApp)

# search for artist

# function: artist name input
FindArtistId <- function(name.of.artist) {
  url.search.name <- paste0("https://api.spotify.com", "/v1/search?q=", name.of.artist, "&type=artist")
  response <- GET(url.search.name, spotifyToken)
  search.results <- fromJSON(toJSON(content(response)))
  ids <- search.results$artists$items$id
  return(ids[1])
}
# end function

# take in artist ID and give the top songs with popularity

top.10.songs <- function(input.ID) {
  artist.get.url <- paste0("https://api.spotify.com", "/v1/artists/", input.ID, "/top-tracks?country=US")
  response.artist <- GET(artist.get.url, spotifyToken)
  artist.results <- fromJSON(toJSON(content(response.artist)))
  top.ten <- select(artist.results$tracks, name, id, popularity, duration_ms)
  return(top.ten)
}

GetAlbums <- function(artist.id) {
  all.albums.URL <- paste0('https://api.spotify.com/v1/artists/', artist.id, '/albums')
  get.albums <- GET(all.albums.URL, spotifyToken) 
  all.albums <- jsonlite::fromJSON(toJSON(content(get.albums)))
  album.genres <- all.albums
  ablum.tracks <- album.genres$tracks$items
}


GetFeatures <- function(track.id) {
  uri <- paste0("https://api.spotify.com/v1/audio-features/", track.id)
  response <- GET(uri, spotifyToken)
  results <- fromJSON(toJSON(content(response)))
}

tracks <- top.10.songs(FindArtistId("david+bowie"))

temp <- data.frame(matrix(unlist(lapply(tracks$id, GetFeatures)), nrow = 10, byrow = 1))
colnames(temp) <- c("danceability", 
                    "energy", 
                    "key", 
                    "loudness", 
                    "mode", 
                    "speechiness", 
                    "acousticness", 
                    "instrumentalness", 
                    "liveness", 
                    "valence", 
                    "tempo", 
                    "type", 
                    "id", 
                    "uri", 
                    "track_href", 
                    "analysis_url", 
                    "duration_ms", 
                    "time_signature")
merged.tracks.features <- cbind(select(tracks, name, popularity), temp)

plot_ly(merged.tracks.features, x = ~loudness, y = ~danceability, z = ~energy, type = 'scatter3d', mode = 'lines', color = ~name)
p <- plot_ly(merged.tracks.features, x = ~loudness, y = ~energy, z = ~duration_ms) %>%
  add_histogram2d()
p
