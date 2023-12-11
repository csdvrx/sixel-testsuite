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

function draw_image(Image,		maxx, maxy, maxcolor, borg, color, s, x, y, yy, sixel, bit, pixel)
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

function real(c)
{
	return substr(c, 1, index(c, SUBSEP) - 1) + 0
}

function imag(c)
{
	return substr(c, index(c, SUBSEP) + 1) + 0
}

function complex(x, y)
{
	return x SUBSEP y
}

function add_complex(c1, c2)
{
	return complex(real(c1) + real(c2), imag(c1) + imag(c2))
}

function mul_complex(c1, c2				, x1, y1, x2, y2)
{
	x1 = real(c1)
	y1 = imag(c1)
	x2 = real(c2)
	y2 = imag(c2)

	return complex(x1*x2 - y1*y2, x1*y2 + y1*x2)
}

function sprint_complex(c)
{
	return "(" real(c) ", " imag(c) ")"
}

function isnan(n)
{
	# Tests true for "inf", "-inf", "nan", "-nan"
	return n == 1/0 || n == -1/0
}

function mandel(c, z)
{
	return add_complex(mul_complex(z, z), c)
}

function iterate_mandel(x, y, iterations			, c, z, i)
{
	c = complex(x, y)
	z = complex(0, 0)

	for (i = 0; i < iterations; i++) {
		z = mandel(c, z)
		if (isnan(real(z))) return i
		if (isnan(imag(z))) return i
	}

	return 0
}

function generate_mandel(Image, ncolors, x1, y1, x2, y2, width, height,
						ite, maxite, x, y, mx, my)
{
	maxite = 1

	print "Generating..."
	for (x = 0; x < width; x++) {
		printf "%3.1f%%\n\033[A", 100 * x / width
		mx = x1 + (x2 - x1) * x / width
		for (y = 0; y < height; y++) {
			my = y1 + (y2 - y1) * y / height
			ite = iterate_mandel(mx, my, 100)
			Image[x, y] = ite
			if (ite > maxite) maxite = ite
		}
	}
	printf "\r          \r"

	# Adjust colors
	print "Adjusting..."
	for (c in Image) {
		Image[c] = int(Image[c] * (ncolors - 1) / maxite)
	}
}

function zoom(Box, quadrant					, x, y)
{
	x = (quadrant == 2 || quadrant == 4)
	y = (quadrant == 1 || quadrant == 2)
	if (x) Box["x1"] = (Box["x1"] + Box["x2"]) / 2
	else   Box["x2"] = (Box["x1"] + Box["x2"]) / 2
	if (y) Box["y1"] = (Box["y1"] + Box["y2"]) / 2
	else   Box["y2"] = (Box["y1"] + Box["y2"]) / 2
}

function draw_mandel(Viewbox, width, height, ncolors			, c, rc)
{
	generate_mandel(Mandel, ncolors, Viewbox["x1"], Viewbox["y1"], Viewbox["x2"], Viewbox["y2"], width, height)

	print "Drawing..."
	print "\033Pq"

	print "#0;2;0;0;0"
	for (c = 1; c < 16; c++) {
		rc = 15 - c
		printf "#%d;2;%d;%d;%d\n", c, int(100 * c / 16), int(sqrt(1000 * sin(c * 3 / 16))), int(100 * sin(c * 3 / 16))
	}

	draw_image(Mandel)

	printf "\033\\"
}

function show_help()
{
	print " 1 | 2"
	print "---+---"
	print " 3 | 4"
	print
	print "Please type a quadrant to zoom in on, and press [Enter]."
	print
	print "Type q [Enter] to quit."
}

BEGIN {
	width = 700
	height = 700
	ncolors = 16
	Viewbox["x1"] = -2.2
	Viewbox["y1"] = -1.5
	Viewbox["x2"] = 0.8
	Viewbox["y2"] = 1.5
	draw_mandel(Viewbox, width, height, ncolors)
	show_help()
}

/^[1-4]$/ {
	zoom(Viewbox, $0)
	draw_mandel(Viewbox, width, height, ncolors)
	print "Quadrant? [1-4]"
}

/^[QqXx]|[Ee][Xx][Ii][Tt]/ {
	exit 0
}

/^[?Hh]/ {
	show_help()
}
