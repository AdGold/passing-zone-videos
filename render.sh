#!/bin/bash

FOLDER="$1"
PREVIEW=$(test "$2" = "-p" && echo "1")
cd $FOLDER
. config
COMMON="../common"

# Get the notation/credits as a PNGs
echo $TITLE > title.txt
xelatex notation.tex
convert -density 500 -quality 100 notation.pdf notation.png
mv notation-0.png notation.png
mv notation-1.png credits.png
rm notation.{aux,log,pdf} title.txt

# Overlay title on intro
FONT="$COMMON/ObelixProB-cyr.ttf"
[[ $TITLE =~ [äöüàèìòùáéíóú] ]] && FONT="$COMMON/bangers.regular.ttf" # Obelix doesn't support accents
ffmpeg -i $COMMON/PZ-INTRO-without-pattern-name.avi -vf "drawtext=fontfile=$FONT: enable='gte(t,1.5)': text='$TITLE': fontcolor=white: fontsize=80: x=(w-text_w)/2: y=(h-text_h-80) + (text_h+80)*(2.5-min(t\,2.5))" -c:a copy -y PZ-intro.mp4
ffmpeg -y -i "PZ-intro.mp4" -f image2 -ss 3 -vframes 1 -an "$TITLE - thumbnail.jpg"

# Trim and fade audio.mp3 here because melt needs exact times
if [ -f audio.mp3 ]; then
    # Use custom audio duration if provided, otherwise calculate it as video duration + 9s (notation + credits + part of intro)
    audio_duration=${AUDIO_DURATION:-$(echo $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 video.mp4) + 9 | bc)}
    non_fade=$(echo $audio_duration - 2 | bc)
    ffmpeg -i audio.mp3 -t $audio_duration -acodec copy -y trimmed_audio.mp3
    ffmpeg -i trimmed_audio.mp3 -af "afade=t=out:st=$non_fade:d=2" -y final_audio.mp3
    rm trimmed_audio.mp3
    MELT="$COMMON/project-music.melt"
else
    MELT="$COMMON/project-nomusic.melt"
fi
[ -f project.melt ] && MELT="project.melt"

# Combine using melt
if [ -n "$PREVIEW" ]; then
    melt melt_file:$MELT 
else
    melt -quiet melt_file:$MELT -consumer "avformat:$TITLE.mp4" acodec=libmp3lame vcodec=libx264 b=12000k quality=high+ width=1920 height=1080 preset=slow profile=high crf=18 threads=4
fi
rm PZ-intro.mp4 credits.png final_audio.mp3
mv notation.png "$TITLE - notation.png"
