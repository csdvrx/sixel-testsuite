#!/bin/bash

# If you want to play
ansi()          { echo -e "\e[${1}m${*:2}\e[0m"; }
bold()          { ansi 1 "$@"; }
italic()        { ansi 3 "$@"; }
underline()     { ansi 4 "$@"; }
strikethrough() { ansi 9 "$@"; }
red()           { ansi 31 "$@"; }

echo "Checking Esc codes:"
echo -e "\t\e[1mbold\e[0m"
echo -e "\t\e[3mitalic\e[0m"
echo -e "\t\e[4munderline\e[0m"
echo -e "\t\e[9mstrikethrough\e[0m"
echo -e "\t\e[31mred\e[0m"
echo
echo "Checking Esc codes combinations:"
echo -e "\t\e[1;33mbold yellow\e[0m"
echo -e "\t\e[1;3;33mbold italic yellow\e[0m"
echo -e "\t\e[1;3;4;33mbold italic underline yellow\e[0m"
echo -e "\t\e[1;3;4;9;33mbold italic underline strikethrough yellow\e[0m"
echo
echo "Checking existing italic and standout settings:"
echo
infocmp $TERM | egrep '(sitm|ritm|smso|rmso)'
echo
echo "Checking that the terminal does the right thing with tput:"
echo -e "\t`tput sitm`italics`tput ritm` `tput smso`standout`tput rmso`"
