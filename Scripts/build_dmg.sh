#!/bin/sh
if ! command -v create-dmg &> /dev/null
then
    echo "create-dmg could not be found. Install it with 'brew install create-dmg'"
    exit 1
fi

cd ../Build
latestBuild=$(ls -t | head -n1)

if [ -z "$latestBuild" ]
then
    echo "No build found"
    exit 1
fi

echo "Latest build found: $latestBuild"

rm -f Leomard.dmg
create-dmg \
    --volname "Leomard Installer" \
    --volicon "../Assets/Icon/DMG/leomard_dmg.icns" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --icon-size 100 \
    --icon "Leomard.app" 200 190 \
    --hide-extension "Leomard.app" \
    --app-drop-link 600 185 \
    "Leomard.dmg" \
    "$latestBuild"

    ## --background "../Assets/Icon/DMG/background.png" \ Maybe one day...
echo "DMG created"
exit 0