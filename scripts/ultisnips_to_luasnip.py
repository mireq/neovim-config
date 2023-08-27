#!/usr/bin/env -S nvim --headless -n -c "pyfile %" -c "q!"
# -*- coding: utf-8 -*-
from pathlib import Path
import vim
import sys
from UltiSnips.text_objects import SnippetInstance
from collections import namedtuple



sys.path.append(str(Path.home().joinpath('.local/share/nvim/lazy/ultisnips/pythonx')))
VisualContent = namedtuple('VisualContent', ['text', 'mode'])


def main():
	from UltiSnips import UltiSnips_Manager
	UltiSnips_Manager.get_buffer_filetypes = lambda: ['scss']
	snippets = UltiSnips_Manager._snips("", True)
	for snippet in snippets:
		instance = snippet.launch('', VisualContent('', 'v'), None, None, None)
		print(instance.get_tabstops())
		#print(instance.__dict__)
		from pprint import pprint
		pprint(instance.__dict__)
		return


if __name__ == "__main__":
	main()
