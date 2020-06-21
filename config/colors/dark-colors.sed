#!/bin/sed -f

# Colorscheme: Solarized Dark

# This sed script applies a color scheme to a template file which defines
# colors only by the placeholders `{{color0}}` through `{{color15}}`.

# The Solarized color schemes use the same set of 16 colors for both light
# and dark variations (https://ethanschoonover.com/solarized/):
#
# ANSI SOLARIZED HEXCODE  ROLE
# ----------------------------
# Base Tones (darkest to lightest)
# dark background tones
# 8    base03    #002b36  (dark background)
# 0    base02    #073542  (dark background highlights)
# content tones
# 10   base01    #586e75  (light emphasized text, dark comments)
# 11   base00    #657b83  (light text)
# 12   base0     #839496  (dark text)
# 14   base1     #93a1a1  (dark emphasized text, light comments)
# light background tones
# 7    base2     #eee8d5  (light background highlights)
# 15   base3     #fdf6e3  (light background)
# Accent Colors
# 3    yellow    #b58900
# 9    orange    #cb4b16
# 1    red       #dc322f
# 5    magenta   #d33682
# 13   violet    #6c71c4
# 4    blue      #268bd2
# 6    cyan      #2aa198
# 2    green     #859900
#
# N.B. The accent colors are used throughtout both dark and light schemes, while
# the base tones undergo a permutation as described below and some switch
# roles, while others are only used in one of the dark or light schemes.
# Dark background tones and the dark text default foreground color are not
# used in the light color scheme and vice versa.
#
# To switch to light mode without altering templates only requires
# transposing each color labeled `base0X` with the color labeled `baseX`,
# e.g. `base01 <-> base1`. This induces the permutation (in standard form):
#   (7 0)(12 11)(14 10)(15 8) 
# on the ANSI terminal color numbers.

# Assign hex color codes to ANSI terminal colors 0-15:
# 8 basic colors and 8 bright/bold ones

s/{{fontsize}}/8/g

# black
s/{{color0}}/#073642/g
s/{{color8}}/#002b36/g
# red
s/{{color1}}/#dc322f/g
s/{{color9}}/#cb4b16/g
# green
s/{{color2}}/#859900/g
s/{{color10}}/#586e75/g
# yellow
s/{{color3}}/#b58900/g
s/{{color11}}/#657b83/g
# blue
s/{{color4}}/#268bd2/g
s/{{color12}}/#839496/g
# magenta
s/{{color5}}/#d33682/g
s/{{color13}}/#6c71c4/g
# cyan
s/{{color6}}/#2aa198/g
s/{{color14}}/#93a1a1/g
# white
s/{{color7}}/#eee8d5/g
s/{{color15}}/#fdf6e3/g
