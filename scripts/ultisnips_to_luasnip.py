#!/usr/bin/env -S nvim --headless -n -c "pyfile %" -c "q"
# -*- coding: utf-8 -*-
from pathlib import Path
import vim
import sys


sys.path.append(str(Path.home().joinpath('.local/share/nvim/lazy/ultisnips/pythonx')))


def main():
	from UltiSnips import UltiSnips_Manager
	print(UltiSnips_Manager._snips("", True))


if __name__ == "__main__":
	main()
