# This code gets the tracks from a playlist then the audio features for those tracks
# and plots them in a graph. I was thinking that this could be made interactive by
# having the user input a playlist key and then make a menu where the user can pick
# what audio feature variable they want to view on the y axis of the graph. To use this
# call the JoysGraph() function.
# The menu of audio feature variables should have these selections: "danceability", "energy", 
# "key", "loudness", "mode", "speechiness", "acousticness", "instrumentalness", "liveness", 
# "valence", "tempo", "duration_ms"


# Set-up
library(devtools)
library(jsonlite)
library(httr)
library(dplyr)
library(plotly)
library(RColorBrewer)

spotifyEndpoint <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", "https://accounts.spotify.com/api/token")
spotifyApp <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
spotifyToken <- oauth2.0_token(spotifyEndpoint, spotifyApp)


# This function gets the audio features for a song.
GetFeatures <- function(track.id) {
  uri <- paste0("https://api.spotify.com/v1/audio-features/", track.id)
  response <- GET(uri, spotifyToken)
  results <- fromJSON(toJSON(content(response)))
  return(results)
}

JoysGraph <- function(spotifyPlaylist) {
  # Mary's code to get the top 50 playlist
  spotifyUser <- 'spotify' 
  songs.URL <- paste0("https://api.spotify.com/v1/users/", spotifyUser, "/playlists/", spotifyPlaylist, "/tracks?fields=items(track)")
  get.Songs <- GET(songs.URL, spotifyToken)
  all.playlist <- jsonlite::fromJSON(toJSON(content(get.Songs)))
  all.songs <- flatten(all.playlist$items)
  #  Creates the dataframe that has the information from the top 50 playlist.
    flat.playlist <- flatten(all.playlist$items) %>% 
      select(track.name, track.album.name, track.explicit, track.popularity, track.id, track.album.album_type)  
  
  
  # This line unlists the audio features and puts them into a data frame
  playlist.audio.features <- data.frame(matrix(unlist(lapply(flat.playlist$track.id, GetFeatures)), nrow = nrow(flat.playlist), byrow = 1))
  # This line changes the data frame column names
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
  # This line binds the track name and popularity columns to the playlist audio features
  playlist.audio.features <- cbind(select(flat.playlist, track.name, track.popularity), playlist.audio.features)
  
  
  # This creates a scatter plot of track name by whatever audio features variable the user selects.
  # In the UI file I was thinking there would be a dropdown menu or radio buttons that the user can
  # select to change what variable is graphed on the y axis.
  
  p <- playlist.audio.features %>% plot_ly(x = ~track.name, y = ~danceability, type = 'scatter', mode = 'markers') %>%
    layout(xaxis = list(showticklabels = FALSE, title = "Track Names"), yaxis = list(title = "Danceability"))
  return(p)
}

# Test Code------------------------------------------------------------------------------------
spotifyPlaylist <- '37i9dQZF1DXcBWIGoYBM5M'

JoysGraph('37i9dQZF1DXcBWIGoYBM5M')


# Below this line is miscellanious code (written by myself and others) that I was using to try to make
# a more complex visualization which was to complicated to figure out in the time provided.
# ---------------------------------------------------------------------------------------------

# search for artist

# function: artist name input
# FindArtistId <- function(name.of.artist) {
#   url.search.name <- paste0("https://api.spotify.com", "/v1/search?q=", name.of.artist, "&type=artist")
#   response <- GET(url.search.name, spotifyToken)
#   search.results <- fromJSON(toJSON(content(response)))
#   ids <- search.results$artists$items$id
#   return(ids[1])
# }
# end function

# take in artist ID and give the top songs with popularity

# top.10.songs <- function(input.ID) {
#   artist.get.url <- paste0("https://api.spotify.com", "/v1/artists/", input.ID, "/top-tracks?country=US")
#   response.artist <- GET(artist.get.url, spotifyToken)
#   artist.results <- fromJSON(toJSON(content(response.artist)))
#   top.ten <- select(artist.results$tracks, name, id, popularity, duration_ms)
#   return(top.ten)
# }

# GetAlbums <- function(artist.id) {
#   all.albums.URL <- paste0('https://api.spotify.com/v1/artists/', artist.id, '/albums?country=US')
#   get.albums <- GET(all.albums.URL, spotifyToken) 
#   all.albums <- jsonlite::fromJSON(toJSON(content(get.albums)))
#   album.list <- all.albums$items
#   album.id <- album.list
# }

# GetAlbumTracks <- function(album.id) {
#   album.tracks.uri <- paste0('https://api.spotify.com/v1/albums/', album.id, '/tracks')
#   get.tracks <- GET(album.tracks.uri, spotifyToken)
#   all.tracks <- jsonlite::fromJSON(toJSON(content(get.tracks)))
#   tracks <- all.tracks
# }

# tracks <- GetAlbums(FindArtistId("david+bowie"))
# all.tracks <- lapply(tracks$id, GetAlbumTracks)
# 
# all.tracks <- data.frame(matrix(unlist(all.tracks$items), nrow = 20, byrow = 1))
# temp <- data.frame(matrix(unlist(lapply(tracks$id, GetFeatures)), nrow = 10, byrow = 1))
# colnames(temp) <- c("danceability", 
#                     "energy", 
#                     "key", 
#                     "loudness", 
#                     "mode", 
#                     "speechiness", 
#                     "acousticness", 
#                     "instrumentalness", 
#                     "liveness", 
#                     "valence", 
#                     "tempo", 
#                     "type", 
#                     "id", 
#                     "uri", 
#                     "track_href", 
#                     "analysis_url", 
#                     "duration_ms", 
#                     "time_signature")
# merged.tracks.features <- cbind(select(tracks, name, popularity), temp)
# 
# plot_ly(merged.tracks.features, x = ~loudness, y = ~danceability, z = ~energy, type = 'scatter3d', mode = 'lines', color = ~name)
# p <- plot_ly(merged.tracks.features, x = ~loudness, y = ~energy, z = ~duration_ms) %>%
#   add_histogram2d()
# p

# UnlistTrackFeatures <- function(track.ids) {
#   temp <- data.frame(
#     matrix(
#       unlist(
#         lapply(
#           track.ids$track.id, GetFeatures)
#       ), nrow = nrow(track.ids), byrow = 1)
#   )
#   colnames(temp) <- c("danceability", 
#                       "energy", 
#                       "key", 
#                       "loudness", 
#                       "mode", 
#                       "speechiness", 
#                       "acousticness", 
#                       "instrumentalness", 
#                       "liveness", 
#                       "valence", 
#                       "tempo", 
#                       "type", 
#                       "id", 
#                       "uri", 
#                       "track_href", 
#                       "analysis_url", 
#                       "duration_ms", 
#                       "time_signature")
#   # temp <- summarise(temp, danceability.avg = mean(as.numeric(danceability)),
#   #                   energy.avg = mean(as.numeric(energy)),
#   #                   loudness.avg = mean(as.numeric(loudness)),
#   #                   speechiness.avg = mean(as.numeric(speechiness)), 
#   #                   acousticness.avg = mean(as.numeric(acousticness)), 
#   #                   instrumentalness.avg = mean(as.numeric(instrumentalness)), 
#   #                   liveness.avg = mean(as.numeric(liveness)), 
#   #                   valence.avg = mean(as.numeric(valence)), 
#   #                   tempo.avg = mean(as.numeric(tempo)), 
#   #                   duration_ms.avg = mean(as.numeric(duration_ms))
#   #                   )
#   return(temp)
# }
# 
# todays.top.hits <-  GetTracks(category.playlist$id[1])
# todays.top.hits <- cbind(select(todays.top.hits, track.name), UnlistTrackFeatures(todays.top.hits))
# RapCaviar <- GetTracks(category.playlist$id[2])
# RapCaviar<- cbind(select(RapCaviar, track.name), UnlistTrackFeatures(RapCaviar))
# RockThis <- GetTracks(category.playlist$id[3])
# RockThis<- cbind(select(RockThis, track.name), UnlistTrackFeatures(RockThis))
# electroNOW <- GetTracks(category.playlist$id[4])
# electroNOW<- cbind(select(electroNOW, track.name), UnlistTrackFeatures(electroNOW))
# HotCountry <- GetTracks(category.playlist$id[5])
# HotCountry<- cbind(select(HotCountry, track.name), UnlistTrackFeatures(HotCountry))

# p <- todays.top.hits %>% plot_ly(x = ~danceability, y = ~acousticness, type = 'scatter')
# p
# # gets the top playlists on spotify
# category.id <- "toplists"
# category.playlist.uri <- paste0("https://api.spotify.com/v1/browse/categories/", category.id, "/playlists", "?country=US")
# category.playlist.response <- GET(category.playlist.uri, spotifyToken)
# category.playlist.results <- fromJSON(toJSON(content(category.playlist.response)))
# category.playlist <- select(category.playlist.results$playlists$items, name, id)


