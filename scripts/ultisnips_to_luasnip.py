#!/usr/bin/env -S nvim --headless -n -c "pyfile %" -c "q!"
# -*- coding: utf-8 -*-
import logging.config
import sys
from collections import namedtuple
from pathlib import Path

from UltiSnips import UltiSnips_Manager
from UltiSnips.snippet.parsing.lexer import tokenize, Position
from UltiSnips.snippet.parsing.ulti_snips import __ALLOWED_TOKENS
from UltiSnips.snippet.parsing.lexer import MirrorToken


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


class LSToken(object):
	__slots__ = []

	def __repr__(self):
		return f'{self.__class__.__name__}()'

	def __str__(self):
		return repr(self)


class LSTextNode(LSToken):
	__slots__ = ['text']

	def __init__(self, text):
		self.text = text

	def __repr__(self):
		return f'{self.__class__.__name__}({self.text})'


def get_text_nodes_between(input, start, end):
	if end is None:
		end = (len(input) - 1, len(input[-1]) - 1)
	text_nodes = []
	for line_num in range(start[0], end[0] + 1):
		col_start = None
		col_end = None
		if line_num == start[0]:
			col_start = start[1]
		if line_num == end[0]:
			col_end = end[1]
		text_fragment = input[line_num][col_start:col_end]
		if text_fragment:
			text_nodes.append(text_fragment)
	return text_nodes


def parse_snippet(snippet):
	snippet_text = snippet._value
	instance = snippet.launch('', VisualContent('', 'v'), None, None, None)
	tokens = tokenize(snippet._value, 0, Position(0, 0), __ALLOWED_TOKENS)
	lines = snippet_text.splitlines()
	print(lines)

	previous_token_end = (0, 0)
	for token in tokens:
		print(get_text_nodes_between(lines, previous_token_end, token.start))
		previous_token_end = token.end
	print(get_text_nodes_between(lines, previous_token_end, None))


	#match type(token):
	#	case MirrorToken:
	#		print()

	from pprint import pprint
	print(list(tokenize(snippet._value, 0, Position(0, 0), __ALLOWED_TOKENS)))



def main():
	UltiSnips_Manager.get_buffer_filetypes = lambda: ['scss']
	snippets = UltiSnips_Manager._snips("", True)
	for snippet in snippets:
		opts = set(snippet._opts)
		unsupported_opts = opts - SUPPORTED_OPTS
		if unsupported_opts:
			for opt in unsupported_opts:
				logger.error("Option %s no supported in snippet %s", opt, snippet.trigger)
			continue

		parse_snippet(snippet)
		return

		#instance = snippet.launch('', VisualContent('', 'v'), None, None, None)
		#print(instance.get_tabstops())
		##print(instance.__dict__)
		#from pprint import pprint
		#pprint(instance.__dict__)
		#return


if __name__ == "__main__":
	main()
