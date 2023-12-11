import sys

class SixelGraphic:
	class Color:
		def __init__(self, r, g, b):
			self.r = self._v(r)
			self.g = self._v(g)
			self.b = self._v(b)

		@staticmethod
		def _v(v):
			v = int(v)
			if v < 0: v = 0
			if v > 100: v = 100
			return v

		def as_sixel(self, n):
			return "#{};2;{};{};{}".format(n, self.r, self.g, self.b)

		def __eq__(self, other):
			if not isinstance(other, self.__class__):
				return false

			return self.r == other.r and self.g == other.g and self.b == other.b

	def __init__(self, fh=sys.stdout):
		self.fh = fh
		self.grid = []
		self.colors = []

	def __enter__(self):
		self.emitln("\033Pq")
		return self

	def __exit__(self, *args):
		self.emitln("\033\\")
		return False

	def set_pixel(self, x, y, color):
		y_index, y_offset = divmod(y, 6)

		#print("x: {}, y: {}, y_index: {}, y_offset: {}".format(x, y, y_index, y_offset))

		while len(self.grid) <= y_index:
			self.grid.append([])

		while len(self.grid[y_index]) <= color:
			self.grid[y_index].append(bytearray())

		while len(self.grid[y_index][color]) <= x:
			self.grid[y_index][color].append(63)

		self.grid[y_index][color][x] = \
			((self.grid[y_index][color][x] - 63) | 2 ** y_offset) + 63

	def set_pixel_rgb(self, x, y, r, g, b):
		c = self.Color(r, g, b)
		for n, tc in enumerate(self.colors):
			if tc == c:
				return self.set_pixel(x, y, n)

		self.colors.append(c)
		return self.set_pixel(x, y, len(self.colors) - 1)

	def display(self):
		for n, c in enumerate(self.colors):
			self.emitln(c.as_sixel(n))

		for a in self.grid:
			for c, line in enumerate(a):
				self.emit("#{}".format(c))
				self.emit(line.decode())
				self.emitln("$")
			self.emitln("-")

	def emit(self, txt):
		print(txt, file=self.fh, end="")

	def emitln(self, txt):
		print(txt, file=self.fh)


if __name__ == '__main__':
	x = SixelGraphic()

	for n in range(33):
		x.set_pixel_rgb(n, n, 100, 0, 0)
		x.set_pixel_rgb(n + 3, n, 0, 100, 0)
		x.set_pixel_rgb(33 - n, n, 0, 0, 100)

	with x:
		x.display()
