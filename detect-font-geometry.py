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

import collections
import os
import re
import sys
import termios
import time

Dimensions = collections.namedtuple("Dimensions", "width height")

class RawTerminal:
	def __enter__(self):
		self.saved_attrs = termios.tcgetattr(0)
		self.saved_blocking = os.get_blocking(0)

		attrs = termios.tcgetattr(0)
		attrs[3] &= ~termios.ICANON
		attrs[3] &= ~termios.ECHO
		termios.tcsetattr(0, termios.TCSADRAIN, attrs)
		os.set_blocking(0, False)

		return self

	def __exit__(self, exc_type, exc_value, traceback):
		termios.tcsetattr(0, termios.TCSADRAIN, self.saved_attrs)
		os.set_blocking(0, self.saved_blocking)

	@staticmethod
	def _interrogate(question, stopseq, answerpattern, timeout=5):
		sys.stdout.write(question)
		sys.stdout.flush()

		r = ""
		c = ""
		noinput = 0
		capture = False

		while True:
			c = sys.stdin.read(1)
			if c == "":
				time.sleep(.1)
				noinput += 1
				if noinput > timeout: return
				continue
			noinput = 0
			if not capture:
				if c != "\033": continue
				capture = True

			r = r + c
			if r.endswith(stopseq): break
			if len(r) >= 65535: return

		if isinstance(answerpattern, str):
			return re.search(answerpattern, r)
		else:
			return answerpattern.search(r)

	def _has_swapped_size_bug(self):
		# gnome-terminal responds with width;height when
		# interrogated with the <ESC>[14t sequence. The correct
		# order is height;width, as per the spec and as correctly
		# implemented in both xterm and mlterm.

		# This method detects when a libvte-based terminal
		# (such as gnome-terminal) is in use, and offers its
		# best guess as to whether the bug is present.

		# That is to say, we currently assume all libvte-based
		# terminals have the bug.

		# Reference for detection:
		# https://gitlab.gnome.org/GNOME/vte/-/issues/235

		m = self.get_DA3()
		if not m: return False
		if m.group(1) != "7E565445": return False # Hex "~VTE"

		return True

		#m = self.get_DA2()
		#if not m: return True # Can't get version - assume bug is present
		#if m.group(2) < 1000000: return True

	def get_size_pixels(self):
		m = self._interrogate("\033[14t", "t", "^\033\\[4;([0-9]+);([0-9]+)t$")
		if m:
			if self._has_swapped_size_bug():
				# Broken libvte terminal emulator
				return Dimensions(int(m.group(1)), int(m.group(2)))
			else:
				return Dimensions(int(m.group(2)), int(m.group(1)))

	def get_size_characters(self):
		m = self._interrogate("\033[18t", "t", "^\033\\[8;([0-9]+);([0-9]+)t$")
		if m: return Dimensions(int(m.group(2)), int(m.group(1)))

	def get_character_cell_size(self):
		m = self._interrogate("\033[16t", "t", "^\033\\[6;([0-9]+);([0-9]+)t$")
		if m: return Dimensions(int(m.group(2)), int(m.group(1)))

		# Well, that didn't work. Let's try the indirect route,
		# and divide canvas size in pixels by canvas size in
		# characters.

		d_pixels = self.get_size_pixels()
		if not d_pixels: return
		d_chars = self.get_size_characters()
		if not d_chars: return

		w = d_pixels.width / d_chars.width
		h = d_pixels.height / d_chars.height

		if w == int(w) and h == int(h): return Dimensions(int(w), int(h))

	def get_DA2(self):
		return self._interrogate("\033[>c", "c", "^\033\\[>([0-9]*);([0-9]*);([0-9]*)c$")

	def get_DA3(self):
		return self._interrogate("\033[=c", "\033\\", "^\033P!\\|([0-9A-F]{8})\033\\\\$")

def show_value(text, format, obj):
	fmo = "(not detected)"
	if obj: fmo=format.format(obj)
	print(text.format(fmo))

if __name__ == '__main__':
	with RawTerminal() as terminal:
		show_value("Your terminal size in pixels [WxH]: {}",
			"{0.width}x{0.height}", terminal.get_size_pixels())
		show_value("Your terminal size in characters [WxH]: {}",
			"{0.width}x{0.height}", terminal.get_size_characters())
		show_value("Your character cell size in pixels [WxH]: {}",
			"{0.width}x{0.height}", terminal.get_character_cell_size())
