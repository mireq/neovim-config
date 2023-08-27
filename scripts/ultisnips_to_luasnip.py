#!/usr/bin/env -S nvim --headless -n -c "pyfile %" -c "q!"
# -*- coding: utf-8 -*-
import logging.config
import sys
from collections import namedtuple
from pathlib import Path

from UltiSnips import UltiSnips_Manager
from UltiSnips.snippet.parsing.lexer import tokenize, Position
from UltiSnips.snippet.parsing.ulti_snips import __ALLOWED_TOKENS
from UltiSnips.snippet.parsing.lexer import MirrorToken, EndOfTextToken, TabStopToken


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
		return f'{self.__class__.__name__}({self.text!r})'


class LSInsertNode(LSToken):
	__slots__ = ['number', 'default']

	def __init__(self, number, default=''):
		self.number = number
		self.default = default

	def __repr__(self):
		return f'{self.__class__.__name__}({self.number!r}, {self.default!r})'


class LSCopyNode(LSToken):
	__slots__ = ['number', 'default']

	def __init__(self, number, default=''):
		self.number = number

	def __repr__(self):
		return f'{self.__class__.__name__}({self.default!r})'


class LSInsertOrCopyNode(LSInsertNode):
	pass


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
			if text_fragment[-1:] == '\n':
				if text_fragment[:-1]:
					text_nodes.append(text_fragment[:-1])
				text_nodes.append('\n')
			else:
				text_nodes.append(text_fragment)
	return [LSTextNode(text) for text in text_nodes]


def parse_snippet(snippet):
	snippet_text = snippet._value
	instance = snippet.launch('', VisualContent('', 'v'), None, None, None)
	tokens = tokenize(snippet._value, 0, Position(0, 0), __ALLOWED_TOKENS)
	lines = snippet_text.splitlines(keepends=True)
	token_list = []

	previous_token_end = (0, 0)
	for token in tokens:
		token_list.extend(get_text_nodes_between(lines, previous_token_end, token.start))
		match token:
			case TabStopToken():
				token_list.append(LSInsertNode(token.number, token.initial_text))
			case MirrorToken():
				token_list.append(LSInsertOrCopyNode(token.number))
			case EndOfTextToken():
				pass
			case _:
				raise RuntimeError("Unknown token: %s" % token)
		previous_token_end = token.end
	token_list.extend(get_text_nodes_between(lines, previous_token_end, None))
	print(token_list)


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
