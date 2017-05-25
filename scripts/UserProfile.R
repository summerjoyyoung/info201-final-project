library(devtools)
library(jsonlite)
library(httr)
library(dplyr)

#This is all the stuff spotify needs to know before you start
spotifyEndpoint <- oauth_endpoint(NULL, "https://accounts.spotify.com/authorize", "https://accounts.spotify.com/api/token")
spotifyApp <- oauth_app("spotify", '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
spotifyToken <- oauth2.0_token(spotifyEndpoint, spotifyApp)

#This is me picking my user and my playlist
#You should be able to get multiple playlists off at once...I will look into this
#I am specifically grabbing the album ID but I think we can do more including song title and artist so we don't
#have to look around for it the second time
spotifyUser <- "1295238919"
spotifyPlaylist <- "3Xu4Lg4n7kYNYgJNg54K6j"

playlistTracksURL <- paste("https://api.spotify.com/v1/users/",
                           spotifyUser,
                           "/playlists/",
                           spotifyPlaylist,
                           "/tracks?fields=total,items(track(album(id)))",
                           sep="")

getTracks <- GET(playlistTracksURL, spotifyToken) 
startPlaylist <- jsonlite::fromJSON(toJSON(content(getTracks)))

total <- as.matrix(startPlaylist[[1]]$track$album$id)

#If there are more than 100 in the playlist, this handles that - need to customize it to what we want
if (startPlaylist$total > 100) {
  offset <- trunc(startPlaylist$total/100)
  for(i in 1:offset) {
    playlistTracksURL <- paste("https://api.spotify.com/v1/users/",
                               spotifyUser,
                               "/playlists/",
                               spotifyPlaylist,
                               "/tracks?fields=items(track(album(id)))&offset="
                               ,i*100,sep="")
    getTracks <- GET(playlistTracksURL, spotifyToken)
    subPlaylist <- jsonlite::fromJSON(toJSON(content(getTracks)))
    total <- rbind(total, as.matrix(subPlaylist[[1]]$track$album$id))
  }
}

#My final data frame with all the album ids
total <- as.data.frame(total)


#This is me successfully getting several albums 
id.list <- '0MhtZHWHKaWHcxbGriNVzs,4Ok5jEpeE2rjELaJYQzeFd,5O0s7Us9XA7lre1xURGve0,4svLfrPPk2npPVuI4kXPYg,3yoNZlqerJnsnMN5EDwwBS'
testalbumsURL <- paste("https://api.spotify.com/v1/albums/?ids=", id.list, sep ="")
getalbums <- GET(testalbumsURL, spotifyToken)
albums <- fromJSON(toJSON(content(getalbums)))
flat.albums <- flatten(albums$albums) %>% select(album_type, genres, id, name, popularity)

#This is me successfully getting a single album
testalbumURL <- paste("https://api.spotify.com/v1/albums/", total[2,1],sep="")
testgetAlbum <- GET(testalbumURL, spotifyToken)
testalbum <- fromJSON(toJSON(content(testgetAlbum)))

test.name <- testalbum$name


