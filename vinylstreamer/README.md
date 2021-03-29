## Description
This raspberry pi will run an icecast server that exposes an internet-radio stream, fed by a liquidsoap defined audiostream using ogg/flac. It will also run a python script `detect_audio.py` that will detect an input audio stream and remotely control an mpd daemon to play the icecast stream

## Required files
- None

## TODO
- [ ] Define on installation the remote ip to control mpd in `detect_audio.py`
