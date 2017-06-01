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
# spotifyPlaylist <- '37i9dQZF1DXcBWIGoYBM5M'
# 
# JoysGraph('37i9dQZF1DXcBWIGoYBM5M')

