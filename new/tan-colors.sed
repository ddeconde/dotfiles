#!/bin/sed -f

# Colorscheme: Gruvbox Light

# This sed script applies a color scheme to a template file which defines
# colors only by the placeholders `{{color0}}` through `{{color15}}`.

# The Gruvbox color schemes (https://github.com/morhetz/gruvbox) draw from two
# intersecting palettes, one for dark mode and one for light mode. In order to
# easily and appropriately apply these colors to the same templates used for
# the Solarized color schemes a subset of 16 of these have been selected and
# matched to the closest Solarized equivalents.
#
# The basic colors red, green yellow, blue, and purple and aqua (equivalent to
# magenta and cyan respectively) which are common to both dark and light
# palettes have been assigned identically the the Solarized accent colors of
# the same names. The orange color common to both palettes has been assigned to
# the role of bright/bold red just as Solarized's orange is. Gruvbox's
# bright/bold purple has been assigned to the role of bright/bold magenta taken
# by the color named violet in Solarized.
#
# The four content colors of Solarized are grays of varying brightness and
# these roles are assigned to 3 Gruvbox tans common to both palettes used for
# background colors in dark mode and foreground colors in light mode, as well
# as 1 light and low chromaticity tan called gray (and assigned to ANSI
# terminal color 8) in the Gruvbox scheme.
#
# Finally, the dark and light background tones of Solarized are replaced by
# the Gruvbox dark mode background and foreground colors whih correspond to
# black and white in standard terminal colors and their bright/bold
# equivalents are drawn from the variants that the Gruvbox palette provides
# for higher contrast modes. The end result is a scheme that behaves like
# Solarized, but based on the core Gruvbox colors:
#
# ANSI SOLARIZED GRUVBOX(D/L) HEXCODE  ROLE
# -----------------------------------------
# Base Tones (darkest to lightest)
# dark background tones
# 8    base03    bg0_h/fg0    #1d2021  (dark background)
# 0    base02    bg0_h/-      #282828  (dark background highlights)
# content tones
# 10   base01    bg2/fg2      #504945  (light emphasized text, dark comments)
# 11   base00    bg3/fg3      #665c54  (light text)
# 12   base0     bg4/fg4      #7c6f64  (dark text)
# 14   base1     gray/gray    #928374  (dark emphasized text, light comments)
# light background tones
# 7    base2     fg/bg0       #ebdbb2  (light background highlights)
# 15   base3     -/bg0_h      #f9f5d7  (light background)
# Accent Colors
# 3    yellow    yellow       #d79921
# 9    orange    orange       #d65d0e
# 1    red       red          #cc241d
# 5    magenta   purple       #b16286
# 13   violet    purple/-     #d3869b
# 4    blue      blue         #458588
# 6    cyan      aqua         #689d6a
# 2    green     green        #cc241d
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
# ANSI SOLARIZED GRUVBOX(D/L) HEXCODE  ROLE
# Base Tones (darkest to lightest)
# dark background tones
# 8    base03    bg0_h/fg0    #1d2021  (dark background)
# 0    base02    bg0_h/-      #282828  (dark background highlights)
# content tones
# 10   base01    bg2/fg2      #504945  (light emphasized text, dark comments)
# 11   base00    bg3/fg3      #665c54  (light text)
# 12   base0     bg4/fg4      #7c6f64  (dark text)
# 14   base1     gray/gray    #928374  (dark emphasized text, light comments)
# light background tones
# 7    base2     fg/bg0       #ebdbb2  (light background highlights)
# 15   base3     -/bg0_h      #f9f5d7  (light background)
# Accent Colors
# 3    yellow    yellow       #d79921
# 9    orange    orange       #d65d0e
# 1    red       red          #cc241d
# 5    magenta   purple       #b16286
# 13   violet    purple/-     #d3869b
# 4    blue      blue         #458588
# 6    cyan      aqua         #689d6a
# 2    green     green        #cc241d

# Assign hex color codes to ANSI terminal colors 0-15:
# 8 basic colors and 8 bright/bold ones

# black
s/{{color0}}/#ebdbb2/g
s/{{color8}}/#f9f5d7/g
# red
s/{{color1}}/#cc241d/g
s/{{color9}}/#d65d0e/g
# green
s/{{color2}}/#98971a/g
s/{{color10}}/#928374/g
# yellow
s/{{color3}}/#d79921/g
s/{{color11}}/#7c6f64/g
# blue
s/{{color4}}/#458588/g
s/{{color12}}/#665c54/g
# magenta
s/{{color5}}/#b16286/g
s/{{color13}}/#d3869b/g
# cyan
s/{{color6}}/#689d6a/g
s/{{color14}}/#504945/g
# white
s/{{color7}}/#282828/g
s/{{color15}}/#1d2021/g
