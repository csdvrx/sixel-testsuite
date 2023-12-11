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

function sixel_multigraph(Data			, x, y, yy, maxy, width, color, colors, sixel, bit, value)
{
	maxy = Data["height"] - 1
	width = Data["width"]
	colors = Data["colors"]
	for (y = maxy + 5 - maxy % 6; y >= 5; y -= 6) {
		for (color = 0; color < colors; color++) {
			printf "#%d", color
			for (x = 0; x < width; x++) {
				sixel = 0
				value = Data[color, x]
				bit = 1
				for (yy = 0; yy < 6; yy++) {
					if (value > y - yy) sixel += bit
					bit *= 2
				}
				printf "%c", sixel + 63
			}
			print "$"
		}
		print "-"
	}
}

function simulate_population(Graph, color, r, iterations, maxy			, y)
{
	population = 1
	for (i = 0; i < iterations; i++) {
		population += population * r * (1 - population / 300)
		y = int(population + 0.5)
		if (y > maxy) maxy = y
		Graph[color, i] = y
	}

	return maxy
}

BEGIN {
	if (r1 == "") r1 = 2.1
	if (r2 == "") r2 = 0.04
	maxy = 0
	Graph["width"] = 300

	maxy = simulate_population(Graph, 0, r1, 300, maxy)
	maxy = simulate_population(Graph, 1, r2, 300, maxy)

	Graph["height"] = maxy + 1
	Graph["colors"] = 2

	print "\033Pq"
	print "#0;2;0;100;0"
	print "#1;2;0;0;100"
	sixel_multigraph(Graph)
	printf "\033\\"
}
