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
	parameters: (parameters [
		(identifier) @arg
		(default_parameter name: (identifier) @arg)
		(dictionary_splat_pattern (identifier) @arg)
		(list_splat_pattern (identifier) @arg)
		(typed_parameter [
			(identifier) @arg
			(list_splat_pattern (identifier) @arg)
			(dictionary_splat_pattern (identifier) @arg)
		])
		(typed_default_parameter name: (identifier) @arg)
	])
)
]
]]
)

local class_query = tsq.parse(
	"python",
[[
[
(class_definition
	name: (identifier) @name
)
]
]]
)

local function copy(args)
	return args[1]
end


local function get_current_python_method(snip)
	local linenr = snip.env.TM_LINE_NUMBER
	local bufnr = vim.api.nvim_get_current_buf()
	local node = ts_utils.get_node_at_cursor()
	local function_definition_node = nil
	local class_definition_node = nil
	local class_name = nil
	local function_name = nil
	local function_parameters = {}
	while node ~= nil do
		if node:type() == 'function_definition' then
			function_definition_node = node
		end
		if node:type() == 'class_definition' then
			class_definition_node = node
			break
		end
		node = node:parent()
	end

	if class_definition_node ~= nil then
		local class_name_node = class_definition_node:field('name')[1]
		class_name = vim.treesitter.get_node_text(class_name_node, bufnr)
	end

	if function_definition_node ~= nil then
		local function_name_node = function_definition_node:field('name')[1]
		function_name = vim.treesitter.get_node_text(function_name_node, bufnr)
		local function_parameters_node = function_definition_node:field('parameters')[1]
		local parameter_num = 1
		for parameter in function_parameters_node:iter_children() do
			parameter_num = parameter_num + 1
			local name = nil
			local parameter_type = parameter:type()
			if parameter_type == 'identifier' then table.insert(function_parameters, vim.treesitter.get_node_text(parameter, bufnr))
			end
		end
	end

	print(class_name, function_name, vim.inspect(function_parameters))

	--print(function_dfinition_node, class_definition_node)
	--print(node:type())
	--print(node:parent():parent():parent():type())
	--local lang_tree = root_lang_tree:language_for_range{ line, col, line, col }
	--local parser = vim.treesitter.get_parser(0, 'python')
	--local syntax_tree = parser:parse()
	--local root = syntax_tree[1]:root()
	--local bufnr = vim.api.nvim_get_current_buf()
	--for _, match, _ in class_query:iter_matches(root, bufnr) do
	--	local lbegin, _, lend, _ = ts_utils.get_vim_range { match[1]:range() }
	--	print("ok")
	--	--print(match[1]:range(), vim.inspect(match), vim.treesitter.get_node_text(match[1], bufnr), vim.treesitter.get_node_text(match[2], bufnr))
	--	--for id, node in pairs(match) do
	--	--	print(id, node, vim.treesitter.get_node_text(node, bufnr))
	--	--end
	--	--local name = vim.treesitter.get_node_text(match[1], bufnr)
	--	--print(name)
	--end
	return 'ok'
end



ls.add_snippets("all", {
	s('cs', {
		f(function(_, snip) print(vim.inspect(snip.env)); return get_current_python_method(snip) end),
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
