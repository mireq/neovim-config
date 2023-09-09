#!/usr/bin/env -S nvim --headless -n -c "pyfile %" -c "q!"
# -*- coding: utf-8 -*-
import argparse
import logging.config
import re
import sys
from io import StringIO
from collections import namedtuple
from datetime import datetime
from pathlib import Path
from typing import List, Tuple, Optional

import vim
from UltiSnips import UltiSnips_Manager
from UltiSnips.snippet.parsing.lexer import tokenize, Position, MirrorToken, EndOfTextToken, TabStopToken
from UltiSnips.snippet.parsing.ulti_snips import __ALLOWED_TOKENS


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
FILE_HEADER = """local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key

"""
logging.config.dictConfig(LOG_CONFIG)
logger = logging.getLogger(__name__)


sys.path.append(str(Path.home().joinpath('.local/share/nvim/lazy/ultisnips/pythonx')))
VisualContent = namedtuple('VisualContent', ['text', 'mode'])
LUA_SPECIAL_CHAR_RX = re.compile(r'("|\'|\n)')


def escape_char(match):
	value = match.group(1)
	if value == '\n':
		return '\\n'
	else:
		return f'\\{value}'


def escape_lua_string(text: str) -> str:
	return f'"{LUA_SPECIAL_CHAR_RX.sub(escape_char, text)}"'


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


class LSInsertOrCopyNode_(LSInsertNode):
	pass


def get_text_nodes_between(input: List[str], start: Tuple[int, int], end: Optional[Tuple[int, int]]):
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
		current_line = input[line_num] if line_num < len(input) else ''
		text_fragment = current_line[col_start:col_end]
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

	insert_nodes = {}
	last_token_number = 0

	previous_token_end = (0, 0)
	for token in tokens:
		token_list.extend(get_text_nodes_between(lines, previous_token_end, token.start))
		match token:
			case TabStopToken():
				node = LSInsertNode(token.number, token.initial_text)
				insert_nodes.setdefault(token.number, node)
				token_list.append(node)
				last_token_number = max(token.number, last_token_number)
			case MirrorToken():
				node = LSInsertOrCopyNode_(token.number)
				insert_nodes.setdefault(token.number, node)
				token_list.append(node)
				last_token_number = max(token.number, last_token_number)
			case EndOfTextToken():
				pass
			case _:
				raise RuntimeError("Unknown token: %s" % token)
		previous_token_end = token.end
	token_list.extend(get_text_nodes_between(lines, previous_token_end, None))

	insert_tokens = set(insert_nodes.values())
	def transform_token(token):
		if isinstance(token, LSInsertOrCopyNode_):
			number = token.number or (last_token_number + 1)
			if token in insert_tokens:
				return LSInsertNode(number, token.default)
			else:
				return LSCopyNode(number)
		return token

	# replace zero tokens and copy or insert tokens
	token_list = [transform_token(token) for token in token_list]

	return token_list


def render_tokens(tokens: List[LSToken]) -> str:
	snippet_body = StringIO()
	at_line_start = True
	if tokens:
		snippet_body.write(',')
	num_tokens = len(tokens)
	for i, token in enumerate(tokens):
		last_token = i == num_tokens - 1
		if at_line_start:
			snippet_body.write('\n\t\t')
			at_line_start = False
		match token:
			case LSTextNode():
				snippet_body.write(f't({escape_lua_string(token.text)})')
			case LSInsertNode():
				if token.default:
					snippet_body.write(f'i({token.number}, {escape_lua_string(token.default)})')
				else:
					snippet_body.write(f'i({token.number})')
			case _:
				raise RuntimeError("Unknown token: %s" % token)
		if not last_token:
			snippet_body.write(',')
			if not at_line_start:
				snippet_body.write(' ')

	return snippet_body.getvalue()


def main():
	#vim.command('redir >> /dev/stdout')
	args = vim.exec_lua('return vim.v.argv')[8:]

	parser = argparse.ArgumentParser("Convert UltiSnips to luasnip snippets")
	parser.add_argument('filetype')
	args = parser.parse_args(args)

	UltiSnips_Manager.get_buffer_filetypes = lambda: [args.filetype]
	snippets = UltiSnips_Manager._snips("", True)
	snippet_code = []
	for snippet in snippets:
		opts = set(snippet._opts)
		unsupported_opts = opts - SUPPORTED_OPTS
		if unsupported_opts:
			for opt in unsupported_opts:
				logger.error("Option %s no supported in snippet %s", opt, snippet.trigger)
			continue

		try:
			tokens = parse_snippet(snippet)
		except Exception as e:
			logger.exception("Parsing error of snippet: %s", snippet.trigger)
			continue

		snippet_body = render_tokens(tokens)
		snippet_code.append(f'\ts({{trig = {escape_lua_string(snippet.trigger)}, descr = {escape_lua_string(snippet.description)}}}{snippet_body}\n\t),\n')
		break



		#instance = snippet.launch('', VisualContent('', 'v'), None, None, None)
		#print(instance.get_tabstops())
		##print(instance.__dict__)
		#from pprint import pprint
		#pprint(instance.__dict__)
		#return
	with open(f'{args.filetype}.lua', 'w') as fp:
		fp.write(f'-- Generated {datetime.now().strftime("%Y-%m-%d")} using ultisnips_to_luasnip.py\n\n')
		fp.write(FILE_HEADER)
		fp.write(f'ls.add_snippets({escape_lua_string(args.filetype)}, {{\n')
		fp.write(''.join(snippet_code))
		fp.write('})\n')


if __name__ == "__main__":
	main()
