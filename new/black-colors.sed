#!/bin/sed -f

# Colorscheme: LowChroma Dark

# This sed script applies a color scheme to a template file which defines
# colors only by the placeholders `{{color0}}` through `{{color15}}`.

# This color scheme is a low chromaticity, though not quite pure
# black/white/gray, palette that maps onto the Solarized color scheme in
# such a way as to provide approximately similar contrast levels on the
# base tones while replacing color accents with somewhat less hue-dependent
# tone differentiation. It also shares the Solarized scheme's relationship
# between the dark and light modes via a permutation of the color
# assignments.
#
# ANSI SOLARIZED HEXCODE LOWCHROMA  ROLE
# --------------------------------------
# Base Tones (darkest to lightest)
# dark background tones
# 8    base03    #002b36 #080808    (dark background)
# 0    base02    #073542 #121212    (dark background highlights)
# content tones
# 10   base01    #586e75 #4e4e4e    (light emphasized text, dark comments)
# 11   base00    #657b83 #444444    (light text)
# 12   base0     #839496 #bcbcbc    (dark text)
# 14   base1     #93a1a1 #b2b2b2    (dark emphasized text, light comments)
# light background tones
# 7    base2     #eee8d5 #eeeeee    (light background highlights)
# 15   base3     #fdf6e3 #f7f7f7    (light background)
# Accent Colors
# 3    yellow    #b58900 #8a8a8a
# 9    orange    #cb4b16 #8b99a7
# 1    red       #dc322f #586674
# 5    magenta   #d33682 #3c6891
# 13   violet    #6c71c4 #6f9ac3
# 4    blue      #268bd2 #808080
# 6    cyan      #2aa198 #6e8091
# 2    green     #859900 #767676
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

# black
s/{{color0}}/#121212/g
s/{{color8}}/#080808/g
# red
s/{{color1}}/#586674/g
s/{{color9}}/#8b99a7/g
# green
s/{{color2}}/#767676/g
s/{{color10}}/#4e4e4e/g
# yellow
s/{{color3}}/#8a8a8a/g
s/{{color11}}/#444444/g
# blue
s/{{color4}}/#808080/g
s/{{color12}}/#bcbcbc/g
# magenta
s/{{color5}}/#3c6891/g
s/{{color13}}/#6f9ac3/g
# cyan
s/{{color6}}/#6e8091/g
s/{{color14}}/#b2b2b2/g
# white
s/{{color7}}/#eeeeee/g
s/{{color15}}/#f7f7f7/g
