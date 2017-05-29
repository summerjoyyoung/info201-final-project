# The R file for Top listened song/playlist/album/artist etc.

library(httr)
library(jsonlite)

spotifyEndpoint <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", "https://accounts.spotify.com/api/token")
spotifyApp <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
spotifyToken <- oauth2.0_token(spotifyEndpoint, spotifyApp)

# This is for the Top 50 Playlist on Spotify
spotifyUser <- 'spotify' 
spotifyPlaylist <- '37i9dQZF1DXcBWIGoYBM5M'

# Getitng the songs from the top 50 playlist
songs.URL <- paste("https://api.spotify.com/v1/users/",
                   spotifyUser, "/playlists/", spotifyPlaylist,
                   "/tracks", sep = "")
get.Songs <- GET(songsURL, spotifyToken)
all.playlist <- jsonlite::fromJSON(toJSON(content(getSongs)))

all.playlist.flat <- flatten(all.playlist$items)

# Creates the dataframe that has the information from the top 50 playlist.
flat.playlist <- flatten(all.playlist$items) %>% 
                 select(track.name, track.album.name, track.explicit, track.popularity,
                 track.album.album_type)  

GetArtist <- function(artist.list){
  artists <- unlist(artist.list)[4]
  return(artists)
}
artists <- lapply(flat.playlist$track.artists, GetArtist)
flat.artists <- unlist(artists)

# Adds the artist name to the dataframe I had created above
flat.playlist$track.artist.name <- flat.artists

