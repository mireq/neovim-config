local group = vim.api.nvim_create_augroup("LargeFileAutocmds", {})
local old_eventignore = false


local default_settings = {
	size_limit = 4 * 1024 * 1024,
	buffer_options = {
		swapfile = false,
		bufhidden = 'unload',
		buftype = 'nowrite',
		undolevels = -1,
	},
	on_large_file_read_pre = function(ev) end
}


local settings = {}


local buf_read_pre = function(ev)
	if ev.file then
		local status, size = pcall(function() return vim.loop.fs_stat(ev.file).size end)
		if status and size > settings.size_limit then
			old_eventignore = vim.o.eventignore
			vim.b[ev.buf].is_large_file = true
			vim.o.eventignore = 'FileType'
			for option, value in pairs(settings.buffer_options) do
				vim.api.nvim_buf_set_var(ev.buf, option, value)
			end
			settings.on_large_file_read_pre(ev)
		end
	end
end


local buf_win_enter = function(ev)
	if old_eventignore ~= false then
		vim.o.eventignore = old_eventignore
		old_eventignore = false
	end
	if vim.b[ev.buf].is_large_file then
		vim.wo.wrap = false
	else
		vim.wo.wrap = vim.o.wrap
	end
end


local buf_enter = function(ev)
	if vim.b[ev.buf].is_large_file then
		if vim.g.loaded_matchparen then
			vim.cmd('NoMatchParen')
		end
	else
		if not vim.g.loaded_matchparen then
			vim.cmd('DoMatchParen')
		end
	end
end


M = {}


M.setup = function(opts)
	if opts == nil then
		opts = {}
	end

	for __, option in ipairs({'size_limit', 'buffer_options', 'on_large_file_read_pre'}) do
		if opts[option] == nil then
			settings[option] = default_settings[option]
		else
			settings[option] = opts[option]
		end
	end

	vim.api.nvim_create_autocmd({"BufReadPre"}, {
		group = group,
		callback = buf_read_pre
	})


	vim.api.nvim_create_autocmd({"BufWinEnter"}, {
		group = group,
		callback = buf_win_enter
	})


	vim.api.nvim_create_autocmd({"BufEnter"}, {
		group = group,
		callback = buf_enter
	})
end


return M
