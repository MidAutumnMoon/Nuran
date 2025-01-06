# This implements the effect that the prompt
# will be at the bottom of terminal on launch,
# and after clear.
#
# See https://asciinema.org/a/661290


# Break down of the escape sequence
#
# \e[0;0H : move cursor to 0,0 to reset its position
# \e[$LINES;0H : move cursor $LINES down
#
# Because this command is executed when shell launches
# before the fisrt prompt is drawn while the cursor
# is sitting at the bottom, as long as no others alter
# the cursor position and the terminal scrolls
# bottom to top, the following outputs should appears
# to be rasing from the bottom.
echo -ne "\e[0;0H\e[$LINES;0H"

# Bind Ctrl+L
bind --user \cl '
    echo -n ( clear | string replace \\e\\[3J "" ) ;
    commandline -f repaint ;
    echo -ne "\e[0;0H\e[$LINES;0H" ;
'
