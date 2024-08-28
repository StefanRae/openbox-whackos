`music_playing` checks wether spotify\_player or mpd is playing music (prioritising spotify), and then print the artist and song into a text file (`current_song`). This way other scripts, in this case a tint2 script, can gather information of the song currently playing on the system.

`tint2.sh` basically structures the artist and song so that it looks nice in the panel. As a bonus, the used ram will be shown if there is no music playing or paused.
