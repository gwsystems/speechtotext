#/bin/bash
# WIP - This does not yet produce output that generates meaningful text-to-speech
sudo apt install ffmpeg --yes
ffmpeg -i Recording.m4a -acodec pcm_s16le -f s16le output.raw
