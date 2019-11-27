> sixel-tmux : a terminal multiplexer that properly display graphics because it does not eat escape sequences

## Usage

To check what your terminal supports:

For the colors:
1. start by 16-colors.sh
2. then try 256-colors.pl
3. see if you are lucky and can use a 24 bits palette with 24-bit-color.sh
4. if it works, try to switch the 16 colors palette between Solarized dark and light with toggle-solarized-dark.sh and toggle-solarized-light.sh

In the final test, after displaying the 4 continous color lines without bands
or sudden breaks, your screen should switch to a black background then back to
a clear yellowish background.

For the fonts:
1. start with `cat font-ansi-blocks.txt` to see block drawing characters and a test bear
2. run `font-vt100.sh` to see the basic box drawing characters
2. `cat font-ansi-box.txt` to see the full set of box drawing characters
3. `cat font-dec.txt` to check DEC VT220 extra characters
4. `cat font-test-all.txt` to check unicode support and overall support of the drawing characters

In the final test, boxes should be properly aligned, and lines should intersect cleanly.

If the font test fails, you may need to change your font as it may not support every character.

Alternatively, when using mlterm you can tell it to extend your preferred font with one or more other fonts, for example:
	ISO8859_1 = Iosevka SS04 18
	ISO8859_15 = Iosevka SS04 18
	ISO10646_UCS2_1 =Iosevka SS04 18
	ISO10646_UCS2_1_BOLD = Iosevka SS04 18
	U+2500-25ff=Segoe UI Symbol
	U+25C6 = Tera Special # Diamond                  ◆
	U+2409 = Tera Special # Horizontal tab           ␉
	U+240C = Tera Special # Form feed                ␌
	U+240D = Tera Special # Carrier return           ␍
	U+240A = Tera Special # Linefeed                 ␊
	U+2424 = Tera Special # Newline                  ␤
	U+240B = Tera Special # Vertical tab             ␋
	U+23BA = Tera Special # Horizontal line 1        ⎺
	U+23BB = Tera Special # Horizontal line  3       ⎻
	U+2500 = Tera Special # Horizontal line  5       ─
	U+23BC = Tera Special # Horizontal line  7       ⎼
	U+23BD = Tera Special # Horizontal line  9       ⎽

### Test passed

You should get something like:

![mintty displaying sixel](https://raw.githubusercontent.com/csdvrx/sixel-testsuite/master/test-passed.jpg)

### Test failed

If the ANSI test fail, you may need a correct terminfo.

Here is an example assuming you use sixel-tmux <https://github.com/csdvrx/sixel-tmux>
1. install sixel-tmux.terminfo: `tic sixel-tmux.terminfo; tic -o ~/.terminfo sixel-tmux.terminfo`
2. start sixel-tmux: `sixel-tmux`
3. select sixel-tmux: `export TERM=sixel-tmux`
4. verify sixel-tmux is used: `tput smglr|base64` should return GzcbWz82OWgbWyVpJXAxJWQ7JXAyJWRzGzg=

