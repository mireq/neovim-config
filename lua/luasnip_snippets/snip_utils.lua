local ls = require("luasnip")
local util = require("luasnip.util.util")
local f = ls.function_node
local rundir = debug.getinfo(1).source:match("@?(.*/)")


local filetype_includes = {}
local filetype_mapping_fp = io.open(rundir .. 'filetype_includes.txt')
if filetype_mapping_fp ~= nil then
	while true do
		local line = filetype_mapping_fp:read('*line')
		if line == nil then
			break
		end
		filetype = nil
		aliases = {}
		for word in line:gmatch("%w+") do
			if filetype == nil then
				filetype = word
			else
				table.insert(aliases, word)
			end
		end
		if filetype ~= nil then
			filetype_includes[filetype] = aliases
		end
	end
	filetype_mapping_fp:close()
end


local function copy_helper(args)
	return args[1]
end

-- Copy node
local function cp(num)
	return f(copy_helper, num)
end

-- Join text
local function jt(args, indent)
	local parts = {}
	for i, part in ipairs(args) do
		if type(part) == 'table' then
			part = table.concat(part, '\n')
		end
		table.insert(parts, part)
	end

	local text = table.concat(parts)
	local lines = {}

	local line_num = 1
	for line in text:gmatch("[^\r\n]+") do
		if line_num == 1 then
			table.insert(lines, line)
		else
			table.insert(lines, indent .. line)
		end
		line_num = line_num + 1
	end

	return lines
end

local function ft_func(num)
	local filetypes = vim.split(vim.bo.filetype, ".", true)
	local visited_filetypes = {}
	for _, filetype in ipairs(filetypes) do
		visited_filetypes[filetype] = true
	end
	for _, filetype in ipairs(filetypes) do
		if filetype_includes[filetype] ~= nil then
			for _, included_filetype in ipairs(filetype_includes[filetype]) do
				if visited_filetypes[included_filetype] == nil then
					visited_filetypes[included_filetype] = true
					table.insert(filetypes, included_filetype)
				end
			end
		end
	end
	return filetypes
end

local function vis()
	return f(function(_, snip)
		return snip.env.TM_SELECTED_TEXT[1] or {}
	end, {})
end

local load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft(filetype_includes)

return {
	cp = cp,
	jt = jt,
	vis = vis,
	ft_func = ft_func,
	load_ft_func = load_ft_func,
}
