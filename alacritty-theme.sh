#!/bin/bash

#--------------------------
### Menu using 'smenu'
#--------------------------

# Modification:
  # // 2021-12-20 Mon 09:55
  # // 2022-02-23 Wed 14:51
    # Note that I quickly tried to get this script to work;
    # Not very familiar with smenu or awk commands;
  # // 2022-08-14 Sun 19:05
    # Changing the config file from alacritty.yml to alacritty-theme.yml
  # // 2022-11-05 Sat 22:14
    # Do some cleanup; put patterns into variables;
    # Fixed problem with string replacement in yml file when
    # there is a duplicate;

# - - - - - - - -

# Variables:

# The string to match for in alacritty-theme.yml file;
# Going to modify the string on this line;
PATTERNMATCH='\- ~/.config/alacritty/themes'
# The alacritty-theme.yml file; search in this file;
YMLFILE="$HOME/.config/alacritty/alacritty-theme.yml"
# Directory of theme folder
THEME_FOLDER="$HOME/.config/alacritty/themes"
# Title Message
# MSG="⎻⎻ SELECT THEME: ⎻⎻(q to exit)"
# MSG="░░░ SELECT THEME (q to exit) ░░░"
# MSG="█── SELECT THEME (q to exit) ──█"
MSG="██ SELECT THEME (q to exit) ██"
# Approx # of max lines per column
MROWS=20

OLD_THEME=
THEMES_LIST=
COUNT=
COL=
NEW_THEME=

# - - - - - - - -

# Grab the current theme;
# use this to preselect in the menu;
# Exclude comment lines; #
OLD_THEME=$(grep -v "#" "$YMLFILE" \
     | grep "$PATTERNMATCH" | awk -F/ '{print $5}')
  # Grep for given string and pass it to awk, which will print the 5th
  # delimited string separated by / character; should be the name of the
  # theme file; For example:
  #  1    2         3        4       5
  # - ~/.config/alacritty/themes/bronze-medallion
  # With -F/ : We set custom separator to /; default is space;

# - - - - - - - -

# Get list of themes, excluding directories;
THEMES_LIST=$(ls -p "$THEME_FOLDER" | grep -v /)
  # ls options:
  # -r : sort reverse order
    # Don't need this anymore
  # -p : appends / to directories; want to diffrentiate files and directories;
  # grep options:
  # -v : invert math; here, match only NOT /
    # In this case, matching only files, excluding folders;


# - - - - - - - -

# Calculate Columns to show: # of themes / maxrows

# Get number of theme files;
COUNT=$(echo "$THEMES_LIST" | wc -w)
  # -w : word count
  # -l : line count
  # In this case, not sure it matters which I use?

# Calculate # of columns we should show; about $MROWS per column
COL=$(($COUNT/$MROWS))
  # arithmetic expansion; doesn't work without ((  ))

# Check COL >= 1
if [[ "$COL" -lt 1 ]]; then
  COL=1
fi


# - - - - - - - -

# Have user select a new theme;
NEW_THEME=$(echo "$THEMES_LIST" \
    | smenu -m "$MSG" -t "$COL" -n200 -d -s "$OLD_THEME")

# Explainer:
  # Same as with fzf; get the directory file listing;
  # Pass to grep, which excludes directories; then pass to smenu;
  # smenu is set for 1 column; we don't want scrollbar; set max lines to 200;
    # The default lines is 5; so 200 should be enough?
  # preselect for the $OLD_THEME string which we gave prior;
  # smenu options:
  # -t [columns]
    # This  option sets the tabulation mode and, if a number is specified,
    # attents to set the number of displayed columns to that number.
    # In this mode, embedded line separators are ignored.
    # The options -A and -Z can nevertheless be used to force words to
    # appear in the first (respectively last) position of the displayed line.
  # -s pattern
    # Place the cursor on the first word corresponding to the specified pattern.
  # -m message
    # Displays a message above the window.
    # If the current locale is not UTF-8, then all UTF-8 characters in
    # it will be converted into a dot.
    # Trying to figure out where the extra blank line comes from; dont' know;
  # -M : Center menu if possible
  # -d
    # Tells the program to clean up the display before quitting by removing the selection window after use as if it was never displayed.
  # -n [lines]
    # Gives the maximum number of lines in the scrolling selection window.
    # If -n is not present the number of lines will be set to 5
  # Is there a way to position the menu? or put borders?


# - - - - - - - -

# Pass the selected menu into sed command; modify theme yml file;

#if [[ -n "$NEW_THEME" ]]; then
if [[ -n "$NEW_THEME" && "$NEW_THEME" != "$OLD_THEME" ]]; then
  # -n : string not null

  # Have to escape forward slash /; so slash the variable patterns;
  # Add slases to our old patternmatch variable
  ESC_PATTERNMATCH=$(echo "$PATTERNMATCH" | sed 's/\//\\\//g')

  # Append the new theme to the pattern match; Replace old with this;
  # Deliberately putting 4 spaces in the line;
  NEW_STRING="    $ESC_PATTERNMATCH\/$NEW_THEME"

  # 1. Need to create a new pattern to search with .* pattern;
  # The .* denotes the theme portion, which we'll replace all;
  # 2. Our line should begin with a space
  # So make sure the pattern begins with a space;
  # Just 1 space minimum necessary; Could use regex * or + matching pattern;
  # * signifies 0 or more times; + denotes 1 or more;
  # If using * pattern, then need to use 2 spaces: "^  *<pattern>"
  # + needs only 1 space: "^ \+<pattern>"
  # + needs to be escaped; but if I used *, didn't need to escape;
  NEW_PATTERNMATCH="^ \+$ESC_PATTERNMATCH\/.*"

  sed -i "s/$NEW_PATTERNMATCH/$NEW_STRING/" "$YMLFILE"
  # Explainer:
    # -i, --in-place : edit files in place
    # s/regexp_search/replacement_string/ :
      # attempt to match regexp against the pattern space;
    # There are 2 parts to the sed command:
      # 1) the replacement string;
      # 2) the input file;
    # The sed replacedment synatax would look something like:
      # "s/- ~\/.config\/alacritty\/themes\/.*/- ~\/.config\/alacritty\/themes\/$NEW_THEME/"
    # The string we're looking for is:
      # - ~\/.config\/alacritty\/themes\/.*
    # And replacing this with:
      # - ~\/.config\/alacritty\/themes\/$NEW_THEME/
    # And we're looking for and replacing the string in the file:
      # ~/.config/alacritty/alacritty-theme.yml


  # Making changes to alacritty-theme.yml doesn't trigger immediate change;
  # The change needs to happen in the alacritty.yml file;
  # So touch the alacritty.yml file to tell alacritty to reload;

fi

touch ~/.config/alacritty/alacritty.yml


# - - - - - - - -


### Old scribbings

  #$ sed -i 's/- ~\/.config\/alacritty\/gruvbox.yml/- ~\/.config\/alacritty\/bronze.yml/' ~/.config/alacritty/alacritty.yml
  #$ sed -ir 's/- ~\/.config\/alacritty\/+yml/- ~\/.config\/alacritty\/gruvbox.yml/' ~/.config/alacritty/alacritty.yml
  #$ sed -i 's/^- ~\/.config\/alacritty\/.*yml/- ~\/.config\/alacritty\/bronze.yml/' ~/.config/alacritty/alacritty.yml
  #sed '/^anothervalue=.*/a after=me' test.txt
  #sed -i 's/- ~\/.config\/alacritty\/themes\/.*yml/- ~\/.config\/alacritty\/themes\/gruvbox.yml/' ~/.config/alacritty/alacritty.yml

  #sed -i 's/- ~\/.config\/alacritty\/themes\/.*/- ~\/.config\/alacritty\/themes\/gruvbox/' ~/.config/alacritty/alacritty.yml

  #echo $(ls ~/.config/alacritty/themes | fzf)

    # -n : string is not null
    # -i, --in-place : edit files in place
    # s/regexp/replacement/ : attempt to match regexp against the pattern space;


    # sed -i "s/- ~\/.config\/alacritty\/themes\/.*/- ~\/.config\/alacritty\/themes\/$NEW_THEME/" ~/.config/alacritty/alacritty.yml
    # grep '\- xx~/.config/alacritty/themes/' alacritty.yml | awk -F/ '{print $5}'



  # The original setup where the theme was changed in the alacritty.yml file
  #sed -i "s/- ~\/.config\/alacritty\/themes\/.*/- ~\/.config\/alacritty\/themes\/$NEW_THEME/" ~/.config/alacritty/alacritty.yml

  # NEW_THEME=$(ls -p "$THEME_FOLDER" \
  # NEW_THEME=$(ls -p "$THEME_FOLDER" \
  #             | grep -v / \
  #             | smenu -m "$MSG" -t2 -n200 -d -s "$OLD_THEME")


### Menu using fzf

  # grep '\- ~/.config/alacritty/themes' alacritty.yml | awk -F/ '{print $5}'
  # sleep 1
    # This would output the currently selected; then we show it; sleep for 1 seconds; then we do fzf below;

  #NEW_THEME=$(ls -r ~/.config/alacritty/themes | fzf)
    # fzf seems to reverse the order; so reverse the sorting to sort alphabetically;

  #NEW_THEME=$(basename -a ~/.config/alacritty/themes/*theme | fzf)
    # Used this when names file extension names and didn't want to show it;
    # basename :
      # strip directory and suffix from filenames
      # -a, --multiple :
        # support multiple arguments; otherwise, only seems to do 1 file at a time;
      # basename seems to act like the ls command, but only gets the basename of the file;
      # when doing ls with *theme filter, it gets the full file path for some reason; don't want that;
      # Don't think can sort with basename

  # // 2022-02-23 Wed 14:46
  # Abandoned using fzf; don't think there's a way to preselect a menu item like smenu below;
  # It's possible to display the original selected; but have to use a timer; the fzf automatically clear screen;


