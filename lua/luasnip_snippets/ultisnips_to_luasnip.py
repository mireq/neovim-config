#!/usr/bin/env -S nvim --headless -n -c "pyfile %" -c "q!"
# -*- coding: utf-8 -*-
from collections import namedtuple, defaultdict
from dataclasses import dataclass
from datetime import datetime
from io import StringIO
from pathlib import Path
from typing import List, Tuple, Optional
import argparse
import logging.config
import operator
import re
import sys

import vim
vim.command('Lazy load ultisnips')
vim.command('Lazy load vim-snippets')

from UltiSnips import UltiSnips_Manager
from UltiSnips.snippet.parsing.base import tokenize_snippet_text
from UltiSnips.snippet.parsing.lexer import tokenize, Position, MirrorToken, EndOfTextToken, TabStopToken, VisualToken, PythonCodeToken
from UltiSnips.snippet.parsing import ulti_snips as ulti_snips_parsing
from UltiSnips.snippet.parsing import snipmate as snipmate_parsing
from UltiSnips.snippet.definition.ulti_snips import UltiSnipsSnippetDefinition
from UltiSnips.snippet.definition.snipmate import SnipMateSnippetDefinition


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
local su = require("luasnip_snippets.snip_utils")
local cp = su.cp
local jt = su.jt
local nl = su.nl
local te = su.te

"""

logging.config.dictConfig(LOG_CONFIG)
logger = logging.getLogger(__name__)


sys.path.append(str(Path.home().joinpath('.local/share/nvim/lazy/ultisnips/pythonx')))
VisualContent = namedtuple('VisualContent', ['text', 'mode'])
LUA_SPECIAL_CHAR_RX = re.compile(r'("|\'|\t|\n)')
INDENT_RE = re.compile(r'^(\s*)')
KNOWN_LANGUAGES = {
	'!p': 'python',
}


def escape_char(match):
	value = match.group(1)
	if value == '\n':
		return '\\n'
	elif value == '\t':
		return '\\t'
	else:
		return f'\\{value}'


def escape_lua_string(text: str) -> str:
	return f'"{LUA_SPECIAL_CHAR_RX.sub(escape_char, text)}"'


def escape_multiline_lua_sting(text: str) -> str:
	equal_signs = 0
	start_delimiter = ''
	end_delimiter = ''
	while True:
		start_delimiter = f'[{"="*equal_signs}['
		end_delimiter = f']{"="*equal_signs}]'
		if start_delimiter not in text and end_delimiter not in text:
			break
		equal_signs += 1
	return f'{start_delimiter}{text}{end_delimiter}'


class OrderedSet(dict):
	def add(self, value: str):
		self[value] = len(self)


class LSNode(object):
	__slots__ = []

	def __repr__(self):
		return f'{self.__class__.__name__}()'

	def __str__(self):
		return repr(self)


class LSTextNode(LSNode):
	__slots__ = ['text']

	def __init__(self, text):
		self.text = text

	def __repr__(self):
		return f'{self.__class__.__name__}({self.text!r})'


class LSInsertNode(LSNode):
	__slots__ = ['number', 'children']

	def __init__(self, number, children=[]):
		self.number = number
		self.children = children

	def __repr__(self):
		return f'{self.__class__.__name__}({self.number!r}, {self.children!r})'


class LSCopyNode(LSNode):
	__slots__ = ['number', 'default']

	def __init__(self, number, default=''):
		self.number = number

	def __repr__(self):
		return f'{self.__class__.__name__}({self.number})'


class LSInsertOrCopyNode_(LSNode):
	__slots__ = ['number', 'children']

	def __init__(self, number, children=[]):
		self.number = number
		self.children = children

	def __repr__(self):
		return f'{self.__class__.__name__}({self.number!r}, {self.children!r})'


class LSVisualNode(LSNode):
	def __init__(self):
		pass

	def __repr__(self):
		return f'{self.__class__.__name__}()'


class LSPythonCodeNode(LSNode):
	__slots__ = ['code']

	def __init__(self, code):
		self.code = code

	def __repr__(self):
		return f'{self.__class__.__name__}({self.code!r})'


@dataclass
class ParsedSnippet:
	attributes: str
	tokens: list[LSNode]

	def get_code(self, indent: int, replace_zero_placeholders: bool = False) -> str:
		tokens = self.tokens
		if replace_zero_placeholders:
			tokens = self.__replace_zero_placeholders(tokens)
		return render_tokens(tokens, indent)

	def __replace_zero_placeholders(self, tokens: list[LSNode]):
		max_placeholder = 0
		for token in tokens:
			if isinstance(token, (LSInsertNode, LSCopyNode)):
				max_placeholder = max(max_placeholder, token.number)
		max_placeholder += 1
		return [LSInsertNode(token.number or max_placeholder, token.children) if isinstance(token, LSInsertNode) else token for token in tokens]


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


def do_tokenize(parent, text, allowed_tokens_in_text, allowed_tokens_in_tabstops, token_to_textobject):
	allowed_tokens = allowed_tokens_in_tabstops if parent else allowed_tokens_in_text
	tokens = list(tokenize(text, '', Position(0, 0) if parent is None else parent.start, allowed_tokens))
	for token in tokens:
		if isinstance(token, TabStopToken):
			token.child_tokens = do_tokenize(token, token.initial_text, allowed_tokens_in_text, allowed_tokens_in_tabstops, token_to_textobject)
			parent_start = token.start
			for child in token.child_tokens:
				child.start -= parent_start
				child.end -= parent_start
		else:
			klass = token_to_textobject.get(token.__class__, None)
			if klass is not None:
				#print(klass)
				#text_object = klass(parent, token)
				pass
	return tokens


def transform_tokens(tokens, lines):
	token_list = []
	insert_nodes = {}

	previous_token_end = (0, 0)
	for token in tokens:
		token_list.extend(get_text_nodes_between(lines, previous_token_end, token.start))
		match token:
			case TabStopToken():
				child_lines = token.initial_text.splitlines(keepends=True) or ['']
				child_tokens = transform_tokens(token.child_tokens, child_lines)
				node = LSInsertNode(token.number, child_tokens)
				insert_nodes.setdefault(token.number, node)
				token_list.append(node)
			case MirrorToken():
				node = LSInsertOrCopyNode_(token.number)
				insert_nodes.setdefault(token.number, node)
				token_list.append(node)
			case VisualToken():
				token_list.append(LSVisualNode())
			case EndOfTextToken():
				pass
			case PythonCodeToken():
				token_list.append(LSPythonCodeNode(token.code))
			case _:
				snippet_text = '\n'.join(lines)
				raise RuntimeError(f"Unknown token {token} in snippet: \n{snippet_text}")
		previous_token_end = token.end
	token_list.extend(get_text_nodes_between(lines, previous_token_end, None))

	insert_tokens = set(token.number for token in insert_nodes.values())
	def finalize_token(token):
		if isinstance(token, LSInsertNode):
			token = LSInsertNode(token.number, token.children)
			insert_tokens.add(token.number)
		elif isinstance(token, LSInsertOrCopyNode_):
			if token.number in insert_tokens:
				token = LSCopyNode(token.number)
			else:
				token = LSInsertNode(token.number, token.children)
				insert_tokens.add(token.number)
		if isinstance(token, LSInsertNode):
			token.children = [finalize_token(child) for child in token.children]
		return token

	# replace zero tokens and copy or insert tokens
	token_list = [finalize_token(token) for token in token_list]

	return token_list


def parse_snippet(snippet):
	snippet_text = snippet._value
	lines = snippet_text.splitlines(keepends=True)
	instance = snippet.launch('', VisualContent('', 'v'), None, None, None)

	if isinstance(snippet, SnipMateSnippetDefinition):
		tokens = do_tokenize(None, snippet._value, snipmate_parsing.__ALLOWED_TOKENS, snipmate_parsing.__ALLOWED_TOKENS_IN_TABSTOPS, snipmate_parsing._TOKEN_TO_TEXTOBJECT)
	else:
		tokens = do_tokenize(None, snippet._value, ulti_snips_parsing.__ALLOWED_TOKENS, ulti_snips_parsing.__ALLOWED_TOKENS, ulti_snips_parsing._TOKEN_TO_TEXTOBJECT)

	if snippet.trigger == 'forr':
		#tokens = tokenize(snippet._value, 0, Position(0, 0), snipmate_parsing.__ALLOWED_TOKENS)
		#print(transform_tokens(tokens, lines))
		#print(snippet._value)
		pass

	#if snippet.trigger == 'pac':
	#	tokens = list(tokens)
	#	tok = tokens[0]
	#	subtokens = list(tokenize(tok.initial_text, '', tok.start, __ALLOWED_TOKENS))
	#	print(subtokens)


	return transform_tokens(tokens, lines)


def token_to_dynamic_text(token: LSNode, related_nodes: dict[int, int]):
	match token:
		case LSTextNode():
			return escape_lua_string(token.text)
		case LSCopyNode():
			return f'args[{related_nodes[token.number]}]'
		case LSVisualNode():
			return 'snip.env.LS_SELECT_DEDENT or {}'
		case _:
			raise RuntimeError("Token not allowed: %s" % token)


def render_tokens(tokens: List[LSNode], indent: int = 0, at_line_start: bool = True) -> str:
	snippet_body = StringIO()
	num_tokens = len(tokens)
	accumulated_text = ['\n']
	for i, token in enumerate(tokens):
		last_token = i == num_tokens - 1
		if at_line_start:
			snippet_body.write('\n' + ('\t' * indent))
			at_line_start = False
		match token:
			case LSTextNode():
				accumulated_text.append(token.text)
				if token.text == '\n':
					at_line_start = True
					snippet_body.write('nl()')
				else:
					snippet_body.write(f't{escape_lua_string(token.text)}')
			case LSInsertNode():
				if token.children:
					#dynamic_node_content = render_tokens(token.children, at_line_start=False)
					#print(dynamic_node_content)
					#snippet_body.write(f'd({token.number}, function(args) return sn(nil, {{{dynamic_node_content}}}) end)')

					node_indent = INDENT_RE.match(''.join(accumulated_text[-operator.indexOf(reversed(accumulated_text), '\n'):])).group(1)

					is_simple = all(isinstance(child, LSTextNode) for child in token.children)
					if is_simple:
						text_content = ''.join(child.text for child in token.children)
						if '\n' in text_content:
							text_content = ', '.join(escape_lua_string(line) for line in text_content.split('\n'))
							snippet_body.write(f'i({token.number}, {{{text_content}}})')
						else:
							snippet_body.write(f'i({token.number}, {escape_lua_string(text_content)})')
					else:
						related_nodes = {}
						for child in token.children:
							if isinstance(child, LSCopyNode):
								if not child.number in related_nodes:
									related_nodes[child.number] = len(related_nodes) + 1
						dynamic_node_content = ', '.join(token_to_dynamic_text(child, related_nodes) for child in token.children)
						related_nodes_code = ''
						if related_nodes:
							related_nodes_code = f', {{{", ".join(str(v) for v in related_nodes.keys())}}}'
						snippet_body.write(f'd({token.number}, function(args, snip) return sn(nil, {{ i(1, jt({{{dynamic_node_content}}}, {escape_lua_string(node_indent)})) }}) end{related_nodes_code})')
				else:
					snippet_body.write(f'i({token.number})')
			case LSCopyNode():
				snippet_body.write(f'cp({token.number})')
			case _:
				raise RuntimeError("Unknown token: %s" % token)
		if not last_token:
			snippet_body.write(',')
			if not at_line_start:
				snippet_body.write(' ')

	return snippet_body.getvalue()


def main():
	args = vim.exec_lua('return vim.v.argv')[8:]

	parser = argparse.ArgumentParser("Convert UltiSnips to luasnip snippets")
	parser.add_argument('filetype')
	args = parser.parse_args(args)

	UltiSnips_Manager.get_buffer_filetypes = lambda: [args.filetype]
	snippets = UltiSnips_Manager._snips("", True)
	snippet_code = defaultdict(list)

	filetype_mapping = {}
	try:
		with open('filetype_includes.txt', 'r') as fp:
			for line in fp:
				line = line.strip()
				if not line:
					continue
				line = line.split()
				filetype_mapping[line[0]] = set(line[1:])
	except FileNotFoundError:
		pass

	included_filetypes = set()

	global_definitions = defaultdict(OrderedSet)

	for snippet in snippets:
		for global_type, global_codes in snippet._globals.items():
			for global_code in global_codes:
				if global_type in KNOWN_LANGUAGES:
					global_definitions[KNOWN_LANGUAGES[global_type]].add(global_code)
				else:
					logger.error("Unknown code block %s", global_type)

		filetype = snippet.location.rsplit(':', 1)[0].split('/')[-1].rsplit('.', 1)[0]

		if filetype != args.filetype:
			included_filetypes.add(filetype)
			continue

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

		#snippet_body = render_tokens(tokens, indent=2)
		snippet_attrs = [f'trig = {escape_lua_string(snippet.trigger)}']
		if snippet.description:
			snippet_attrs.append(f'descr = {escape_lua_string(snippet.description)}')
		snippet_attrs.append(f'priority = {snippet.priority}')
		snippet_attrs.append(f'trigEngine = te({escape_lua_string(snippet._opts)})')
		snippet_code[snippet.trigger].append(ParsedSnippet(
			attributes=", ".join(snippet_attrs),
			tokens=tokens
		))
		#snippet_code[snippet.trigger].append(f'\ts({{{", ".join(snippet_attrs)}}}, {{{snippet_body}\n\t}}),\n')

	code_globals = {}
	for language, global_list in global_definitions.items():
		code_globals[language] = ', '.join(f'\t{escape_lua_string(code_block)}\n' for code_block in global_list)

	with open(f'{args.filetype}.lua', 'w') as fp:
		fp.write(f'-- Generated {datetime.now().strftime("%Y-%m-%d")} using ultisnips_to_luasnip.py\n\n')
		fp.write(FILE_HEADER)
		if code_globals:
			fp.write('\n')
			fp.write(''.join(f'local {language}_globals = {{\n{global_list}}}\n' for language, global_list in code_globals.items()))
			fp.write('\n\n')
		fp.write(f'ls.add_snippets({escape_lua_string(args.filetype)}, {{\n')
		for snippet_list in snippet_code.values():
			parsed_snippet = snippet_list[0]
			if len(snippet_list) == 1:
				fp.write(f'\ts({{{parsed_snippet.attributes}}}, {{{parsed_snippet.get_code(indent=2)}\n\t}}),\n')
			else:
				snippet_choices = []
				for parsed_snippet in snippet_list:
					snippet_choices.append(f'\t\t{{{parsed_snippet.get_code(indent=3, replace_zero_placeholders=True)}\n\t\t}},\n')
				fp.write(f'\ts({{{parsed_snippet.attributes}}}, c(1, {{\n{"".join(snippet_choices)}\t}})),\n')
		#fp.write(''.join(snippet_code))
		fp.write('})\n')

	filetype_mapping.setdefault(args.filetype, [])
	filetype_mapping[args.filetype] = list(set(filetype_mapping[args.filetype]).union(included_filetypes))
	with open('filetype_includes.txt', 'w') as fp:
		for filetype, included_filetypes in filetype_mapping.items():
			if not included_filetypes:
				continue
			fp.write(f'{filetype} {" ".join(included_filetypes)}\n')


if __name__ == "__main__":
	main()
