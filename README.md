# Alacritty-theme

#### Alacritty terminal theme changer


Assumes that your alacritty config files are in ~/.config/alacritty

Copy the content of this folder to ~/.config/alacritty/

Themes are in the themes folder.

You can use the alacritty-theme.yml file in the folder or your own.

If using your own, make sure to copy this at the end of the file:
 
```
import:
  - ~/.config/alacritty/alacritty-theme.yml
```


To use:

```
$ . /path/to/alacritty-theme.sh
```

Then pick a theme.

Recommended that you make an alias in your .bashrc file like so:

alias alacritty-theme='. ~/.config/alacritty/alacritty-theme.sh'

Then just do:

```
$ alacritty-theme
```
