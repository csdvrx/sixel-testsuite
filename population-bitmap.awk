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

function draw_image(Image,		maxx, maxy, maxcolor, borg, color, s, x, y, sixel, bit, pixel)
{
	maxx = -1
	maxy = -1
	maxcolor = -1

	# Determine dimensions
	for (borg in Image) {
		color = Image[borg]
		s = index(borg, SUBSEP)
		x = int(substr(borg, 1, s - 1))
		y = int(substr(borg, s + 1))
		if (maxx < x) maxx = x
		if (maxy < y) maxy = y
		if (color != "" && maxcolor < color) maxcolor = color
	}

	# Sixelize
	for (y = maxy + 6 - maxy % 6; y >= 5; y -= 6) {
		for (color = 0; color <= maxcolor; color++) {
			printf "#%d", color
			for (x = 0; x <= maxx; x++) {
				sixel = 0
				bit = 1
				for (yy = 0; yy < 6; yy++) {
					pixel = Image[x, y - yy]
					if (pixel != "" && pixel == color) sixel += bit
					bit *= 2
				}
				printf "%c", sixel + 63
			}
			print "$"
		}
		print "-"
	}
}

function sgn(x)
{
	if (x < 0) return -1
	if (x > 0) return 1
	return 0
}

function simulate_population(Image, color, r, iterations		, population, i, y, prev_y)
{
	population = 1
	prev_y = 1
	for (i = 0; i < iterations; i++) {
		population += population * r * (1 - population / 300)
		if (population < 0) population = 0
		y = int(population + 0.5)
		do {
			prev_y += sgn(y - prev_y)
			Image[i, prev_y] = color
		} while (prev_y != y)
	}
}

function run_program(Args, nargs)
{
	for (color = 0; color < nargs - 1; color++)
		simulate_population(Figure, color, Args[color + 1], 750)

	print "\033Pq"
	print "#0;2;50;50;50"
	#print "#1;2;0;100;0"

	draw_image(Figure)

	printf "\033\\"
}

BEGIN {
	Defaultratios[1] = 2.4
	Defaultratios[2] = 0.04

	if (ARGC > 1)	run_program(ARGV, ARGC)
	else		run_program(Defaultratios, 3)
}
