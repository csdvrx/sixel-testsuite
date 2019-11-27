#!/bin/sh
echo "You should see basic thin lines used for drawing boxes"
echo
for i in 6a 6b 6c 6d 6e 71 74 75 76 77 78; do
 printf "0x$i \x$i \x1b(0\x$i\x1b(B\n"
done
