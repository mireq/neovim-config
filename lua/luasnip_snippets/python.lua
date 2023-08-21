local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")
local ts_utils = require("nvim-treesitter.ts_utils")
local tsq = vim.treesitter.query

local method_definition_query = tsq.parse(
	"python",
[[
[
(function_definition
	name: (identifier) @name
	parameters: (parameters
		(parameter) @arg
	)
)
]
]]
)

local function copy(args)
	return args[1]
end


local function get_current_python_method()
	local parser = vim.treesitter.get_parser(0, 'python')
	local syntax_tree = parser:parse()
	local root = syntax_tree[1]:root()
	local bufnr = vim.api.nvim_get_current_buf()
	for _, match, _ in method_definition_query:iter_matches(root, bufnr) do
		local lbegin, _, lend, _ = ts_utils.get_vim_range { match[1]:range() }
		print(match[1]:range(), vim.inspect(match), vim.treesitter.get_node_text(match[1], bufnr), vim.treesitter.get_node_text(match[2], bufnr))
		print(match[2]:named_child_count())
		for id, node in pairs(match) do
			print(id, node)
		end
		local name = vim.treesitter.get_node_text(match[1], bufnr)
		print(name)
	end
	return 'ok'
end



ls.add_snippets("all", {
	s('cs', {
		f(function(_, snip) return get_current_python_method() end),
		t('('),
		i(0),
		t(')')
	})
	---- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
	--s("fn", {
	--	-- Simple static text.
	--	t("//Parameters: "),
	--	-- function, first parameter is the function, second the Placeholders
	--	-- whose text it gets as input.
	--	f(copy, 2),
	--	t({ "", "function " }),
	--	-- Placeholder/Insert.
	--	i(1),
	--	t("("),
	--	-- Placeholder with initial text.
	--	i(2, "int foo"),
	--	-- Linebreak
	--	t({ ") {", "\t" }),
	--	-- Last Placeholder, exit Point of the snippet.
	--	i(0),
	--	t({ "", "}" }),
	--})
})
