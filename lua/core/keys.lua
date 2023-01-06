local term = require("term")
local cmd = vim.cmd

-- Disable help
vim.keymap.set('', '<F1>', '')
--
-- Navigation with C-up / C-down
vim.keymap.set('', '<C-j>', 'gj')
vim.keymap.set('', '<C-k>', 'gk')
--
-- Remap home
vim.keymap.set('', '<Home>', '^')
vim.keymap.set('i', '<Home>', '<C-O>^', {silent=true})

-- common completion
vim.keymap.set('i', '<C-Space>', '<C-X><C-O>')
vim.keymap.set('i', '<Nul>', '<C-X><C-O>')


-- Adjust indent
vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave"}, {
	callback = function()
		vim.keymap.set('x', '<Tab>', '>gv')
		vim.keymap.set('x', '<BS>', '<gv')
	end
})
--
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- => Build
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- Run make
-- map <F9> :make -j 2<CR>
vim.api.nvim_set_keymap('', '<F9>', ':make -j 2<CR>', {})
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- => Terminal
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vim.keymap.set('n', '<F2>', term.toggle)
vim.keymap.set('t', '<C-w>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:lua require("term").toggle()<CR>')

-- Save with ctrl+s
vim.keymap.set('n', '<C-S>', function() cmd("w") end)
vim.keymap.set('i', '<C-S>', function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false); cmd('w') end)
