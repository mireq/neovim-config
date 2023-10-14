local ls = require("luasnip")
local util = require("luasnip.util.util")
local f = ls.function_node
local t = ls.text_node
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

-- New line
local nl = function() return t{"", ""} end

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

local function split_at_whitespace(text)
	local words = {}
	local position = 1
	for space in string.gmatch(text, '()%s') do
		table.insert(words, string.sub(text, position, space - 1))
		position = space + 1
	end
	table.insert(words, string.sub(text, position))

	return words
end

function arrays_equal(a, b)
	if #a ~= #b then
		return false
	end

	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end

	return true
end

function str_strip(s, chars)
	return string.gsub(s, '^[%s]*(.-)[%s]*$', '%1')
end


local function words_for_line(trigger, before, num_words)
	-- Gets the final 'num_words' words from 'before'.
	-- If num_words is nil, then use the number of words in 'trigger'.
	if num_words == nil then
		num_words = #split_at_whitespace(trigger)
	end

	word_list = split_at_whitespace(before)
	if #word_list <= num_words then
		return str_strip(before)
	else
		before_words = before
		for i = 1, num_words do
			local left = before_words:reverse():find(word_list[i]:reverse())
			if left then
				before_words = before_words:sub(1, #word_list[i] - left)
			end
		end
		return str_strip(before:sub(#before_words + 1))
	end
end


local function is_keyword_char(char)
	local is_keyword = vim.fn.search("\\<" .. char .. "\\>", "nw")
	return is_keyword ~= 0
end


local function trig_engine(opts)
	local function engine(trigger)
		local function matcher(line_to_cursor, trigger)

			if opts:find('w') ~= nil then
				local trigger_words = split_at_whitespace(trigger)
				local words = words_for_line(trigger, line_to_cursor)
				local words_len = #trigger
				local words_prefix = string.sub(words, 1, -words_len - 1)
				local words_suffix = string.sub(words, -words_len)
				local match = words_suffix == trigger
				if match and #words_prefix > 0 then
					match = vim.fn.match(string.sub(words_prefix, -1), '\\k') == -1
				end

				if match then
					local begin = #line_to_cursor - line_to_cursor:reverse():find(trigger:reverse()) - #trigger
					return trigger, {begin, begin + #trigger}
				end
			end

			return nil
		end
		return matcher
	end
	return engine
end

local load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft(filetype_includes)

return {
	cp = cp,
	jt = jt,
	nl = nl,
	te = trig_engine,
	vis = vis,
	ft_func = ft_func,
	load_ft_func = load_ft_func,
}
