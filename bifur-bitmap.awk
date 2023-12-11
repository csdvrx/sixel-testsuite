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

function run_population(Image, color, x, r, height		, p, i)
{
	p = 0.5
	for (i = 0; i < 500; i++) p = r * p * (1 - p)
	for (i = 0; i < 500; i++) {
		p = r * p * (1 - p)
		Image[x, int(0.5 * p * height)] = color
	}
}

function bifurcate(Image, color, rmax, width, height, rmin		, x, r)
{
	if (rmin == "") rmin = 1

	for (x = 0; x < width; x++) {
		r = rmin + (rmax - rmin) * (x / width)
		run_population(Image, color, x, r, height)
	}
}

function run_program(Args, nargs)
{
	bifurcate(Figure, 3, 4, 450, 600)

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
