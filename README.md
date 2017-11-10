# Snatch

Snatch is a Rails web app with one simple function, to add whichever song is currently playing on Spotify to a designated playlist.

It works by first first asking for Spotify account access through OAuth, then using the resulting keys to consume the Spotify API, query the currently playing song and the user's playlists then depending on the results:

* Create a playlist if one with the designated name is not found.
* Add the song to the playlist and flash a positive result message.
* Don't add the song and flash a negative result message because the song was already present in the playlist.

