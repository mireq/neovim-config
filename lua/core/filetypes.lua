-- pyton settings
vim.g.python_recommended_style = 0
vim.g.pyindent_open_paren = 'shiftwidth()'
vim.g.pyindent_continue = 'shiftwidth()'
vim.g.pyindent_close_paren = '-shiftwidth()'

--vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile", "BufEnter"}, {
--	pattern = {'*.py'},
--	callback = function()
--		if vim.b.pymode_rope_project_root == nil then
--			local filename = vim.fn.expand("%:p:h") .. ';'
--			local rope_dir = vim.fn.finddir('.ropeproject', filename)
--			if rope_dir == '' then
--				rope_dir = vim.env['HOME'] .. '/.ropeproject'
--				vim.b.pymode_rope_project_root = ''
--			else
--				vim.b.pymode_rope_project_root = vim.fn.fnamemodify(rope_dir, ':p:h:h')
--			end
--		end
--		vim.g.pymode_rope_project_root = vim.b.pymode_rope_project_root
--	end
--})

-- Highlight whitespace

vim.api.nvim_create_autocmd({"ColorScheme"}, {
	command = 'highlight ExtraWhitespace ctermbg=red guibg=red'
})
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
	pattern = {'*.cpp', '*.h', '*.hpp', '*.php', '*.py', '*.css', '*.js', '*.html', '*.xhtml', '*.htm'},
	command = "match ExtraWhitespace /\\s\\+$\\| \\+\\ze\\t/",
})
vim.api.nvim_create_autocmd({"InsertEnter"}, {
	pattern = {'*.cpp', '*.h', '*.hpp', '*.php', '*.py', '*.css', '*.js', '*.html', '*.xhtml', '*.htm'},
	command = "match ExtraWhitespace /\\s\\+\\%#\\@<!$\\| \\+\\ze\\t\\%#\\@<!/",
})
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
	pattern = {'*.cpp', '*.h', '*.hpp', '*.php', '*.py', '*.css', '*.js', '*.html', '*.xhtml', '*.htm'},
	command = "match ExtraWhitespace /\\s\\+$\\| \\+\\ze\\t/",
})
