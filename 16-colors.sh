#!/bin/sh

echo "Bright toggle=2 separate color matrices of 8x8, showing"
echo "foreground/background colors, bg as rows, fg as columns"
echo
echo "Normal:"
for bg in 0 1 2 3 4 5 6 7 ; do
  echo -ne "\e[4$bg"
  echo -n "m"
  case $bg in
   0) echo -n "black  ";;
   1) echo -n "  red  ";;
   2) echo -n " green ";;
   3) echo -n "yellow ";;
   4) echo -n " blue  ";;
   5) echo -n "magenta";;
   6) echo -n " cyan  ";;
   7) echo -n " white ";;
  esac
  for fg in 0 1 2 3 4 5 6 7 ; do
      echo -ne "\e[3$fg"
      echo -n "m"
      case $fg in
       0) echo -n "black  ";;
       1) echo -n "  red  ";;
       2) echo -n " green ";;
       3) echo -n "yellow ";;
       4) echo -n " blue  ";;
       5) echo -n "magenta";;
       6) echo -n " cyan  ";;
       7) echo -n " white ";;
      esac
      # reset
      echo -ne "\e[39m"
  done
  # reset and newline
  echo -e "\e[49m"
 done

echo
echo "Brightness on:"
for bg in 0 1 2 3 4 5 6 7 ; do
  echo -ne "\e[10$bg"
  echo -n "m"
  case $bg in
   0) echo -n "black  ";;
   1) echo -n "  red  ";;
   2) echo -n " green ";;
   3) echo -n "yellow ";;
   4) echo -n " blue  ";;
   5) echo -n "magenta";;
   6) echo -n " cyan  ";;
   7) echo -n " white ";;
  esac
  for fg in 0 1 2 3 4 5 6 7 ; do
      echo -ne "\e[9$fg"
      echo -n "m"
      case $fg in
       0) echo -n "black  ";;
       1) echo -n "  red  ";;
       2) echo -n " green ";;
       3) echo -n "yellow ";;
       4) echo -n " blue  ";;
       5) echo -n "magenta";;
       6) echo -n " cyan  ";;
       7) echo -n " white ";;
      esac
      # reset
      echo -ne "\e[39m"
  done
  # reset and newline
  echo -e "\e[49m"
 done
echo
echo
