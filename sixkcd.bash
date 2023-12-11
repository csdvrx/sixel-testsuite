#!/bin/bash

# Display an xkcd comic using sixel graphics. Show the comic <number> if
# given, or the latest comic by default.
#
# Press any key to show the alt text and exit.

# Dependencies:
# - img2sixel ("apt-get install libsixel-bin")
# - python 3.x ("apt-get install python3")
# - curl or wget ("apt-get install curl")
# - torsocks (optional, make requests through tor)

# [ User Parameters ] #########################################################

xkcdnumber="$1"

# [ Global Configuration ] ####################################################

TORIFY=( torsocks -i )
type -p "${TORIFY[0]}" > /dev/null || TORIFY=()

# [ Functions ] ###############################################################

# Print a message to standard error and exit with a non-zero status code

error: ()
{
	echo Error: "$*" 1>&2
	exit 127
}

# Word Wrap (stdin -> stdout) with auto terminal width detection
#
# Prefer "par" if detected, otherwise fall back via "fmt" to "cat".

wordwrap ()
{
	local width="$1"
	local defaultwidth="${2:-"80"}"
	local ww

	[ "$width" ] || tty <&1 > /dev/null || width="$defaultwidth"
	[ "$width" ] || width="$COLUMNS"
	[ "$width" ] || width="$( tput cols <&1 )"
	[ "$width" ] || width="$defaultwidth"

	ww=( cat )
	[ -x /usr/bin/fmt ] && ww=( /usr/bin/fmt -w "$width" )
	[ -x /usr/bin/par ] && ww=( /usr/bin/par "$width" )

	"${ww[@]}"
}

# Fetch URL and output contents to stdout

fetch_url ()
{
	local url="$1"

	if type -p curl > /dev/null; then
		"${TORIFY[@]}" curl -sSL "$url"
	elif type -p wget > /dev/null; then
		"${TORIFY[@]}" wget --no-verbose --retry-on-host-error -O - -- "$url"
	fi
}

# Fetch xkcd metadata by its comic number, or latest if omitted.
# Writes to stdout.

fetch_xkcd ()
{
	local xkcdnumber="$1"
	local url

	if [ "$xkcdnumber" ]; then
		url="https://xkcd.com/"$xkcdnumber"/info.0.json"
	else
		url="https://xkcd.com/info.0.json"
	fi

	fetch_url "$url"
}

# Read xkcd json from stdin, output selected values on stdout:
# Line 1: xkcd number
# Line 2: safe_title
# Line 3: URL of comic image
# Line 4: year
# Line 5: month
# Line 6: day
# Line 7+: "Alt" text

decode_xkcd ()
{
	python3 -c 'if __name__ == "__main__":
		import json
		import sys
		j = json.load(sys.stdin)
		for k in "num safe_title img year month day alt".split():
			print(j[k])'
}

# [ Main ] ####################################################################

# Display xkcd number ASAP if known, but don't advance the line, so we
# can overwrite it with json data when that arrives. Doing it this way
# allows us to have a single code path, regardless of whether we already
# know the xkcd number.

echo -n "$xkcdnumber "

# Download and extract

xkcd_data="$( fetch_xkcd "$xkcdnumber" | decode_xkcd )" \
	|| error: Download failed

xkcd_number="$( echo "$xkcd_data" | awk 'NR==1' )"
xkcd_safe_title="$( echo "$xkcd_data" | awk 'NR==2' )"
xkcd_imgurl="$( echo "$xkcd_data" | awk 'NR==3' )"
xkcd_year="$( echo "$xkcd_data" | awk 'NR==4' )"
xkcd_month="$( echo "$xkcd_data" | awk 'NR==5' )"
xkcd_day="$( echo "$xkcd_data" | awk 'NR==6' )"
xkcd_alt="$( echo "$xkcd_data" | awk 'NR>6' )"

# Display (before image)

printf '\r%s (%04d-%02d-%02d)\n' "$xkcd_number" "$xkcd_year" "$xkcd_month" "$xkcd_day"
echo
echo "$xkcd_safe_title" | wordwrap
echo

# Download image

xkcd_siximg="$( fetch_url "$xkcd_imgurl" | img2sixel )" \
	|| error: Image download failed

# Display (image, alt text)

echo "$xkcd_siximg"
read -rsn 1
echo "$xkcd_alt" | wordwrap
echo
