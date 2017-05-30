library(devtools)
library(jsonlite)
library(httr)
library(dplyr)
library(plotly)

#Takes in a user ID and returns a dataset of all the tracks in the user's public playlists
GetTracksDataset <- function(user.id){
  #Getting authorization from the user to access their public playlists
  spotifyR <- oauth_endpoint(authorize = "https://accounts.spotify.com/authorize", access = "https://accounts.spotify.com/api/token")
  myapp <- oauth_app('Trendy Tunes', '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
  spotify.Token <- oauth2.0_token(spotifyR, myapp, scope = "playlist-modify-public")
  
  #Gets all the user's playlists and puts them in a data frame named flat.all.user.playlists.
  #Removes all the playlists that aren't theirs. 
  all.user.playlists.URL <- paste('https://api.spotify.com/v1/me/playlists', sep = "")
  get.playlists <- GET(all.user.playlists.URL, spotify.Token) 
  all.user.playlists <- jsonlite::fromJSON(toJSON(content(get.playlists)))
  flat.all.user.playlists <- flatten(all.user.playlists$items) %>% 
    select(id, name, public, external_urls.spotify, tracks.href, tracks.total, owner.id) %>% 
    filter(owner.id == user.id)
  
  #Gets all the user's songs and puts them in a data frame named flat.tracks
  GetTracks <- function(playlist.id){
    get.row <- flat.all.user.playlists %>% filter(unlist(id) == playlist.id)
    num.songs <- unlist(get.row$tracks.total)
    offset <- 0
    first.time <- TRUE
    
    #If there are more than 100 songs in the playlist, get all the songs
    if(num.songs > 100){
      while(num.songs > 100 && num.songs > 0){
        tracks.url <- paste(unlist(get.row$tracks.href), "/?offset=", offset, sep = "")
        get.tracks <- GET(tracks.url, spotify.Token)
        all.tracks <- fromJSON(toJSON(content(get.tracks)))
        my.tracks <- flatten(all.tracks$items) %>% 
          select(track.duration_ms, added_at, track.artists, track.id, track.name, 
                 track.popularity, track.album.artists, track.album.id, track.album.name) %>% 
          filter(!is.null(track.album.name))
        
        if(first.time){
          flat.tracks <- my.tracks
          first.time <- FALSE
        } else {
          flat.tracks <- rbind(flat.tracks, my.tracks)
        }
        offset <- offset + 100
        num.songs <- num.songs - 100
      }
      tracks.url <- paste(unlist(get.row$tracks.href), "/?offset=", offset, sep = "")
      get.tracks <- GET(tracks.url, spotify.Token)
      all.tracks <- fromJSON(toJSON(content(get.tracks)))
      my.tracks <- flatten(all.tracks$items) %>% select(track.duration_ms, added_at, track.artists, track.id, track.name, track.popularity, track.album.artists, track.album.id, track.album.name)
      flat.tracks <- rbind(flat.tracks, my.tracks)
    } else {
      tracks.url <- unlist(get.row$tracks.href)
      get.tracks <- GET(tracks.url, spotify.Token)
      all.tracks <- fromJSON(toJSON(content(get.tracks)))
      flat.tracks <- flatten(all.tracks$items) %>% select(track.duration_ms, added_at, track.artists, track.id, track.name, track.popularity, track.album.artists, track.album.id, track.album.name)
    }
    return(flat.tracks)
  }
  
  
  tracks <- lapply(flat.all.user.playlists$id, GetTracks)
  flat.tracks <- do.call(rbind, tracks)
  
  #Gets the artists for each of the songs and puts them in a single column
  GetArtist <- function(artist.list){
    artists <- unlist(artist.list)[4]
    return(artists)
  }
  
  artists <- lapply(flat.tracks$track.album.artists, GetArtist)
  flat.artists <- unlist(artists)
  
  #Adds the extra column to flat.tracks
  flat.tracks$artist.name <- flat.artists
  
  return(flat.tracks)
}

#Takes in a dataset of the user's tracks and returns the duration of all their songs in hours
GetDuration <- function(tracks.dataset){
  spotifyR <- oauth_endpoint(authorize = "https://accounts.spotify.com/authorize", access = "https://accounts.spotify.com/api/token")
  myapp <- oauth_app('Trendy Tunes', '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
  spotify.Token <- oauth2.0_token(spotifyR, myapp, scope = "playlist-modify-public")
  
  duration.ms <- unlist(tracks.dataset$track.duration_ms) %>% sum()
  duration.hours <- round(duration.ms / 3600000, 2)
  
  return(duration.hours)
}

#Takes in a dataset of the user's tracks and creates a graph, plotting the track vs track popularity
CreateGraph <- function(tracks.dataset){
  popular.tracks <- tracks.dataset %>% select(track.id, track.name, track.popularity, artist.name)
  
  average.popularity <- round(unlist(popular.tracks$track.popularity) %>% sum() / nrow(popular.tracks), 0)
  
  plot_ly(popular.tracks, x = ~track.name, y = ~track.popularity, type = "scatter", hoverinfo = "text",
          text = ~paste("Song: ", unlist(track.name), "</br> Artist: ", as.list(artist.name), "</br> Populartiy: ", unlist(track.popularity), sep = "")) %>%  
    layout(xaxis = list(showticklabels = FALSE, title = "Your Songs"), yaxis = list(title = "Popularity"),
           title = "The Popularity of Your Songs")
}


#Takes in a user ID and returns the display image URL
GetImage <- function(user.id){
  spotifyR <- oauth_endpoint(authorize = "https://accounts.spotify.com/authorize", access = "https://accounts.spotify.com/api/token")
  myapp <- oauth_app('Trendy Tunes', '87ccb0dca2bc4cac82d82a731fa65295', '5094f0bd6d4b4a368a990909d2a15acd')
  spotify.Token <- oauth2.0_token(spotifyR, myapp, scope = "playlist-modify-public")
  
  
  user.profile.url <- paste('https://api.spotify.com/v1/users/', user.id, sep = "")
  get.user.profile <- GET(user.profile.url, spotify.Token)
  user.profile <- fromJSON(toJSON(content(get.user.profile)))
  display.image <- flatten(user.profile$images)$url
  return(display.image)
}



