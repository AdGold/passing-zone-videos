# Passing Zone video maker

This is a simple script to make videos for [Passing Zone](http://passing.zone), along with setups for videos I've uploaded.

## Installation

Install dependencies
```
sudo apt install texlive-xetex imagemagick ffmpeg melt
mkdir -p ~/.fonts
cp common/*.ttf ~/.fonts
fc-cache -f -v
```

Clone repo
```
git clone https://github.com/AdGold/passing-zone-videos.git
```

## Usage

Create a folder with the following files
* `config`: config file with the following fields:
  * `TITLE="Title"`: the title of the video
  * `INTRO_TITLE="Intro Title"` (optional): the title to use in the intro video overlay, defaults to the same as `TITLE`
  * `AUDIO_DURATION=10` (optional): the duration of the audio clip in seconds (defaults to just under the total video duration)
* `notation.tex`: the notation and credits as a latex document
* `video.mp4`: the video clip
* `audio.mp3` (optional): the music to add
* `project.melt` (optional): the melt file to define the project if non-standard (can normally be left out)

Existence of an `audio.mp3` file will add music to the video and use a slightly different default melt file which mutes the audio of the video clip.

Run `./render.sh <folder name> [-p]`

The `-p` flag will preview the video in `melt` instead of rendering it.

This will create two files:
* `<title>.mp4` - the output video
* `<title> - notation.png` - the notation as a PNG
