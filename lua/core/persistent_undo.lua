local function get_undo_filename()
	local undo = vim.fn.undofile(vim.fn.expand('%'))
	return vim.fn.escape(undo, '%% ')
end


local function get_backup_name()
	return vim.o.backupdir .. vim.fn.substitute(vim.fn.expand('%:p'), '/', '%', 'g') .. '~~'
end


function is_undofile_sane()
	if vim.fn.filereadable(vim.fn.undofile(vim.fn.expand('%'))) == 1 then
		local undo_filename = get_undo_filename()

		local finished = true
		local ok, err = pcall(function()
			local output = vim.fn.execute('rundo ' .. undo_filename)
			if not output:match('Finished reading undo file') then
				finished = false
			end
		end)
		if finished then
			return true
		end
		return false
	end
	return true
end


function restore_undo()
	local undo_filename = get_undo_filename()
	local backup_name = get_backup_name()

	if vim.fn.filereadable(backup_name) == 1 then
		vim.cmd('silent %!cat ' .. vim.fn.escape(backup_name, '%% '))
		local ok, err = pcall(function()
			vim.fn.execute('rundo ' .. undo_filename)
		end)
		vim.cmd('silent %!cat ' .. vim.fn.expand('%:p'))
	end
end


vim.api.nvim_create_autocmd({"BufRead"}, {
	callback = function()
		if not is_undofile_sane() then
			restore_undo()
		end
	end
})


vim.api.nvim_create_autocmd({"BufWritePost"}, {
	callback = function()
		local backup_name = get_backup_name()
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local ok, err = pcall(vim.fn.writefile, lines, backup_name)
	end
})
