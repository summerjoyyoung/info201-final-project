library(devtools)
library(jsonlite)
library(httr)
library(dplyr)
library(plotly)
library(RColorBrewer)

spotifyEndpoint <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", "https://accounts.spotify.com/api/token")
spotifyApp <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
spotifyToken <- oauth2.0_token(spotifyEndpoint, spotifyApp)

# This is for the Top 50 Playlist on Spotify
spotifyUser <- 'spotify' 
spotifyPlaylist <- '37i9dQZF1DXcBWIGoYBM5M'

# Getitng the songs from the top 50 playlist
songs.URL <- paste("https://api.spotify.com/v1/users/", spotifyUser, "/playlists/", spotifyPlaylist, "/tracks", sep = "")
get.Songs <- GET(songs.URL, spotifyToken)
all.playlist <- jsonlite::fromJSON(toJSON(content(get.Songs)))

all.playlist.flat <- flatten(all.playlist$items)

# Creates the dataframe that has the information from the top 50 playlist.
flat.playlist <- flatten(all.playlist$items) %>% 
  select(track.name, track.album.name, track.explicit, track.popularity, track.id, track.album.album_type)  

GetFeatures <- function(track.id) {
  uri <- paste0("https://api.spotify.com/v1/audio-features/", track.id)
  response <- GET(uri, spotifyToken)
  results <- fromJSON(toJSON(content(response)))
}

playlist.audio.features <- data.frame(matrix(unlist(lapply(flat.playlist$track.id, GetFeatures)), nrow = nrow(flat.playlist), byrow = 1))
colnames(playlist.audio.features) <- c("danceability", 
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
playlist.audio.features <- cbind(flat.playlist, playlist.audio.features)







------------------------------------------------------------------------------------------------------

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
  all.albums.URL <- paste0('https://api.spotify.com/v1/artists/', artist.id, '/albums?country=US')
  get.albums <- GET(all.albums.URL, spotifyToken) 
  all.albums <- jsonlite::fromJSON(toJSON(content(get.albums)))
  album.list <- all.albums$items
  album.id <- album.list
}

GetAlbumTracks <- function(album.id) {
  album.tracks.uri <- paste0('https://api.spotify.com/v1/albums/', album.id, '/tracks')
  get.tracks <- GET(album.tracks.uri, spotifyToken)
  all.tracks <- jsonlite::fromJSON(toJSON(content(get.tracks)))
  tracks <- all.tracks
}



tracks <- GetAlbums(FindArtistId("david+bowie"))
all.tracks <- lapply(tracks$id, GetAlbumTracks)

all.tracks <- data.frame(matrix(unlist(all.tracks$items), nrow = 20, byrow = 1))
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
