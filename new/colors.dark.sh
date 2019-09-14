#!/usr/bin/env bash

# Colorscheme: Solarized Dark

#
# Color Definitions
#
# Define color name variables by color hex codes.
#

# Base Tones (darkest to lightest)
# dark background tones
base03='#002b36'
base02='#073542'
# content tones
base01='#586e75'
base00='#657b83'
base0='#839496'
base1='#93a1a1'
# light background tones
base2='#eee8d5'
base3='#fdf6e3'
# Accent Colors
yellow='#b58900'
orange='#cb4b16'
red='#dc322f'
magenta='#d33682'
violet='#6c71c4'
blue='#268bd2'
cyan='#2aa198'
green='#859900'

#
# Color Assignments
#
# Assign color name variables to the 16 basic (8 dark and 8 bright) ANSI colors
# (color0,...,color15) terminal colors.
#

# black dark/light
color0=$base02
color8=$base03
# red dark/light
color1=$red
color9=$orange
# green dark/light
color2=$green
color10=$base01
# yellow dark/light
color3=$yellow
color11=$base00
# blue dark/light
color4=$blue
color12=$base0
# magenta dark/light
color5=$magenta
color13=$violet
# cyan dark/light
color6=$cyan
color14=$base1
# white dark/light
color7=$base2
color15=$base3

# Template Color Substitution

#
# SCRIPT
#

main () {
  if [[ $# -eq 0 ]]; then
    display_colors
  elif [[ $# -eq 2 ]]; then
    apply_colors "$1" "$2"
  else
    usage
  fi
}


#
# Functions
#

apply_colors () {
  sed -e "s/{{COLOR0}}/$color0/g" \
      -e "s/{{COLOR0}}/$color1/g" \
      -e "s/{{COLOR2}}/$color2/g" \
      -e "s/{{COLOR3}}/$color3/g" \
      -e "s/{{COLOR4}}/$color4/g" \
      -e "s/{{COLOR5}}/$color5/g" \
      -e "s/{{COLOR6}}/$color6/g" \
      -e "s/{{COLOR7}}/$color7/g" \
      -e "s/{{COLOR8}}/$color8/g" \
      -e "s/{{COLOR9}}/$color9/g" \
      -e "s/{{COLOR10}}/$color10/g" \
      -e "s/{{COLOR11}}/$color11/g" \
      -e "s/{{COLOR12}}/$color12/g" \
      -e "s/{{COLOR13}}/$color13/g" \
      -e "s/{{COLOR14}}/$color14/g" \
      -e "s/{{COLOR15}}/$color15/g" <"$1" >"$2"
}

usage () {
  # print usage message from here doc
cat <<EOF
usage: $(basename $0) [TEMPLATE CONFIG]
Print colors to be applied to templates if called without arguments.
Apply colors to TEMPLATE file to create CONFIG file with arguments.
EOF
  exit 64
}

echo_error () {
  # conveniently print errors to stderr
  printf "$0: $@\n" >&2
}

# Return a colour that contrasts with the given colour
# Bash only does integer division, so keep it integral
contrast_color () {
    local r g b luminance
    color="$1"

    if (( color < 16 )); then # Initial 16 ANSI colors
        (( color == 0 )) && printf "15" || printf "0"
        return
    fi

    # Greyscale # rgb_R = rgb_G = rgb_B = (number - 232) * 10 + 8
    if (( color > 231 )); then # Greyscale ramp
        (( color < 244 )) && printf "15" || printf "0"
        return
    fi

    # All other colors:
    # 6x6x6 color cube = 16 + 36*R + 6*G + B  # Where RGB are [0..5]
    # See http://stackoverflow.com/a/27165165/5353461

    # r=$(( (color-16) / 36 ))
    g=$(( ((color-16) % 36) / 6 ))
    # b=$(( (color-16) % 6 ))

    # If luminance is bright, print number in black, white otherwise.
    # Green contributes 587/1000 to human perceived luminance - ITU R-REC-BT.601
    (( g > 2)) && printf "0" || printf "15"
    return

    # Uncomment the below for more precise luminance calculations

    # # Calculate percieved brightness
    # # See https://www.w3.org/TR/AERT#color-contrast
    # # and http://www.itu.int/rec/R-REC-BT.601
    # # Luminance is in range 0..5000 as each value is 0..5
    # luminance=$(( (r * 299) + (g * 587) + (b * 114) ))
    # (( $luminance > 2500 )) && printf "0" || printf "15"
}


# Print a coloured block with the number of that colour
print_color () {
  local color="$1"
    #local color="$1" contrast
    #contrast=$(contrast_colour "$1")
  printf "\e[48;5;%sm" "$color"                # Start block of colour
    #printf "\e[38;5;%sm%3d" "$contrast" "$colour" # In contrast, print number
  printf "\e[0m "                               # Reset colour
}

# Starting at $1, print a run of $2 colours
display_colors () {
  local i
  for (( i = 0; i < 16; i++ )) do
      print_color "$i"
  done
  printf "  "
}


#
# RUN MAIN()
#

main "$@"
exit 0
