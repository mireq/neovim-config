local group = vim.api.nvim_create_augroup("LargeFileAutocmds", {})


vim.api.nvim_create_autocmd({"BufReadPre"}, {
	group = group,
	callback = function(ev)
		if ev.file then
			local status, size = pcall(function() return vim.loop.fs_stat(ev.file).size end)
			if status and size > 1024 * 1024 then -- large file
				vim.wo.wrap = false
				vim.o.eventignore = 'FileType'
				vim.bo.swapfile = false
				vim.bo.bufhidden = 'unload'
				vim.bo.buftype = 'nowrite'
				vim.bo.undolevels = -1
				vim.cmd('NoMatchParen')
			else
				vim.o.eventignore = nil
				vim.cmd('DoMatchParen')
			end
		end
	end
})

vim.api.nvim_create_autocmd({"BufEnter"}, {
	group = group,
	callback = function(ev)
		local byte_size = vim.api.nvim_buf_get_offset(ev.buf, vim.api.nvim_buf_line_count(ev.buf))
		if byte_size > 1024 * 1024 then
			vim.cmd('NoMatchParen')
		else
			vim.cmd('DoMatchParen')
		end
	end
})
