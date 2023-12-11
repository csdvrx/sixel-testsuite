#!/usr/bin/awk

# Copyright (C) 2020 by Coffee (@Coffee@toot.cafe)

# you may redistribute and/or modify this file under the terms of
# the GNU Affero General Public License, version 3 or later. The full
# text of this license can be found in the file called LICENSE, which
# should have been distributed along with this file. If not, try the
# following sources:

# https://gitlab.com/Matrixcoffee/sixel-experiments/blob/master/LICENSE
# https://spdx.org/licenses/AGPL-3.0-or-later.html
# https://www.gnu.org/licenses/

# SPDX-License-Identifier: AGPL-3.0-or-later

function add_sixel(row, x, y		, c, nc)
{
	c = substr(row, x + 1, 1)
	if (c == "") c = "?"
	nc = index(SIXELS, c) - 1
	nc += 2^y
	return substr(row, 1, x) substr(SIXELS, nc + 1, 1) substr(row, x + 2)
}

BEGIN {
	SIXELS = "?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

	population = 1
	row = ""
	if (r == "") r = 1.1
	y = 0
	print "\033Pq#0;2;0;100;0"
	for (i = 0; i < 300; i++) {
		population += population * r * (1 - population / 500)
		for (x = 0; x < population; x++) {
			row = add_sixel(row, x, y, 1)
		}
		y++
		if (y > 5) {
			printf "#0%s$-\n", row
			y = 0
			row = ""
		}
	}
	printf "\033\\"
}
