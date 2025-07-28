#!/bin/bash

# set -x

# https://material-theme.com/docs/reference/color-palette/

# Material Ocean
# background": "#0F111A",
# "grey": "#3B4252",
# "cyan": "#89ddff",
# "blue": "#82aaff",
# "foreground": "#ffffff",
# "green": "#c3e88d",
# "red": "#ff5370",
# "yellow": "#ffcb6b"

#!/bin/bash

getcolor() {

    color_name=$1
    opacity=$2

    local o100=0xff
    local o75=0xbf
    local o50=0x80
    local o25=0x40
    local o10=0x1a
    local o0=0x00

    local blue=#5E81AC
    local teal=#EBCB8B
    local cyan=#88C0D0
    local grey=#3B4252
    local green=#A3BE8C
    local yellow=#D08770
    local red=#BF616A
    local black=#2E3440
    local white=#ECEFF4

    # local blue=#6272A4
    # local teal=#F1FA8C
    # local cyan=#8BE9FD
    # local grey=#3b4252
    # local green=#50FA7B
    # local yellow=#FFB86C
    # local red=#FF5555
    # local black=#282A36
    # local white=#F8F8F2

    case $opacity in
        75) local opacity=$o75 ;;
        50) local opacity=$o50 ;;
        25) local opacity=$o25 ;;
        10) local opacity=$o10 ;;
        0) local opacity=$o0 ;;
        *) local opacity=$o100 ;;
    esac

    case $color_name in
        blue) local color=$blue ;;
        teal) local color=$teal ;;
        cyan) local color=$cyan ;;
        grey) local color=$grey ;;
        green) local color=$green ;;
        yellow) local color=$yellow ;;
        red) local color=$red ;;
        black) local color=$black ;;
        white) local color=$white ;;
        *) 
            echo "Invalid color name: $color_name" >&2
            return 1
            ;;
    esac

    echo $opacity${color:1}
}

# Test the function
# getcolor white 75


# Bar and item colors
export BAR_COLOR=$(getcolor black 25)
export BAR_BORDER_COLOR=$(getcolor black 50)
export HIGHLIGHT=$(getcolor white)
export HIGHLIGHT_75=$(getcolor cyan 75)
export HIGHLIGHT_50=$(getcolor cyan 50)
export HIGHLIGHT_25=$(getcolor cyan 25)
export HIGHLIGHT_10=$(getcolor cyan 10)
export ICON_COLOR=$(getcolor white)
export ICON_COLOR_INACTIVE=$(getcolor white 50)
export LABEL_COLOR=$(getcolor white 75)
export POPUP_BACKGROUND_COLOR=$(getcolor black 25)
export POPUP_BORDER_COLOR=$(getcolor black 0)
export SHADOW_COLOR=$(getcolor black)
export TRANSPARENT=$(getcolor black 0)

