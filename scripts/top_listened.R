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
songsURL <- paste("https://api.spotify.com/v1/users/",
                   spotifyUser, "/playlists/", spotifyPlaylist,
                   "/tracks", sep = "")
getSongs <- GET(songsURL, spotifyToken)
startPlaylist <- jsonlite::fromJSON(toJSON(content(getSongs)))

# According to GitHub- order should be:
# Track(Artist + Title), Album, Playlist