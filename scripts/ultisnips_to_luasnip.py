#!/usr/bin/env -S nvim --headless -n -c "pyfile %" -c "q!"
# -*- coding: utf-8 -*-
import logging.config
import sys
from collections import namedtuple
from pathlib import Path


SUPPORTED_OPTS = {'w'}

LOG_CONFIG = {
	'version': 1,
	'formatters': {
		'fmt': {'format': "%(levelname)s: %(message)s"}
	},
	'handlers': {
		'console': {
			'class':'logging.StreamHandler',
			'formatter':'fmt',
			'level':logging.DEBUG
		},
	},
	'root':{
		'handlers':('console',)
	}
}
logging.config.dictConfig(LOG_CONFIG)
logger = logging.getLogger(__name__)


sys.path.append(str(Path.home().joinpath('.local/share/nvim/lazy/ultisnips/pythonx')))
VisualContent = namedtuple('VisualContent', ['text', 'mode'])


def main():
	from UltiSnips import UltiSnips_Manager
	from UltiSnips.snippet.parsing.lexer import tokenize, Position
	from UltiSnips.snippet.parsing.ulti_snips import __ALLOWED_TOKENS

	UltiSnips_Manager.get_buffer_filetypes = lambda: ['scss']
	snippets = UltiSnips_Manager._snips("", True)
	for snippet in snippets:
		opts = set(snippet._opts)
		unsupported_opts = opts - SUPPORTED_OPTS
		if unsupported_opts:
			for opt in unsupported_opts:
				logger.error("Option %s no supported in snippet %s", opt, snippet.trigger)
			continue

		instance = snippet.launch('', VisualContent('', 'v'), None, None, None)
		from pprint import pprint
		print(list(tokenize(snippet._value, 0, Position(0, 0), __ALLOWED_TOKENS)))
		return

		#instance = snippet.launch('', VisualContent('', 'v'), None, None, None)
		#print(instance.get_tabstops())
		##print(instance.__dict__)
		#from pprint import pprint
		#pprint(instance.__dict__)
		#return


if __name__ == "__main__":
	main()
