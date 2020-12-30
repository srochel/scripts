#!/bin/bash
for f in *.dv; do
  ffmpeg -i  "$f" -deinterlace -vcodec h264 -acodec mp3 "${f%.dv}.mp4"
  ffmpeg -i "$f" -pix_fmt yuv420p -preset slow -y "${f%.dv}-2.mp4"
done
