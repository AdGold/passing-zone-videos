#!/bin/bash

# Required setup:
# sudo apt install texlive-xetex imagemagick ffmpeg melt
# mkdir -p ~/.fonts
# cp common/*.ttf ~/.fonts
# fc-cache -f -v

FOLDER="$1"
cd $FOLDER
TITLE="$(cat title.txt)"
COMMON="../common"

# Get the notation as a PNG
xelatex notation.tex
convert -density 500 -quality 100 notation.pdf notation.png
mv notation-0.png notation.png
mv notation-1.png credits.png
rm notation.aux notation.log notation.pdf

# Overlay title on intro
# Check if name contains an accent - if so we can't use Obelix so use a similar font
if [[ $TITLE == *[äöüàèìòùáéíóú]* ]]; then
    FONT="$COMMON/bangers.regular.ttf"
else
    FONT="$COMMON/ObelixProB-cyr.ttf"
fi
ffmpeg -i $COMMON/PZ-INTRO-without-pattern-name.avi -vf "drawtext=fontfile=$FONT: enable='gte(t,1.5)': text='$TITLE': fontcolor=white: fontsize=80: x=(w-text_w)/2: y=(h-text_h-80) + (text_h+80)*(2.5-min(t\,2.5))" -c:a copy -y PZ-intro.mp4

# Trim and fade audio.mp3 here because melt needs exact times
if [ -f audio.mp3 ]; then
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 video.mp4)
    # Intro is 5s, notation and credits are 4s each, minus some overlaps
    audio_duration=$(echo $duration + 11 | bc)
    non_fade=$(echo $audio_duration - 2 | bc)
    ffmpeg -i audio.mp3 -t $audio_duration -acodec copy -y trimmed_audio.mp3
    ffmpeg -i trimmed_audio.mp3 -af "afade=t=out:st=$non_fade:d=2" -y final_audio.mp3
else
    touch final_audio.mp3
fi

# Combine using melt
melt -quiet melt_file:project.melt -consumer avformat:output.mp4 acodec=libmp3lame vcodec=libx264 b=12000k quality=high+ width=1920 height=1080 preset=slow profile=high crf=18
rm PZ-intro.mp4 credits.png trimmed_audio.mp3 final_audio.mp3
mv output.mp4 "$TITLE.mp4"
mv notation.png "$TITLE - notation.png"

