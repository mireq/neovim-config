# -*- coding: utf-8 -*-
import vim


def hello():
	print("hello called")
	print(vim.vars.get('snip_utils_kwargs', {}))
