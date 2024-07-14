--local term = require("term")
local cmd = vim.cmd

-- Disable help
vim.keymap.set('', '<F1>', '')
--
-- Navigation with C-up / C-down
vim.keymap.set('', '<C-j>', 'gj')
vim.keymap.set('', '<C-k>', 'gk')
vim.keymap.set('i', '<C-e>', '<C-o>$')
vim.keymap.set('i', '<C-a>', '<C-o>^')
vim.keymap.set('i', '<C-h>', '<left>')
vim.keymap.set('i', '<C-l>', '<right>')
vim.keymap.set('i', '<C-y>', '<BS>')

-- Tabs
vim.keymap.set('n', '<C-q>', '<Cmd>tabclose<CR>')

-- Remap home
vim.keymap.set('', '<Home>', '^')
vim.keymap.set('i', '<Home>', '<C-O>^', {silent=true})

-- common completion
vim.keymap.set('i', '<C-Space>', '<C-X><C-O>')
vim.keymap.set('i', '<Nul>', '<C-X><C-O>')

-- nohlsearch on esc
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>')


-- Adjust indent
vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave"}, {
	callback = function()
		vim.keymap.set('x', '<Tab>', '>gv')
		vim.keymap.set('x', '<BS>', '<gv')
	end
})

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Snippets
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
vim.keymap.set('i', '\\...', '…')
--
-- " Better completion for {
local function insert_parentheses(first, last)
	return function()
		local win = vim.api.nvim_get_current_win()
		local cursor = vim.api.nvim_win_get_cursor(win)
		local current_buf = vim.api.nvim_get_current_buf()
		local line = vim.api.nvim_get_current_line()
		local _, _, indent = string.find(line, "^([ \t]*)")
		vim.api.nvim_buf_set_text(current_buf, cursor[1]-1, cursor[2], cursor[1]-1, cursor[2], {first, indent, indent .. last})
		local keys = vim.api.nvim_replace_termcodes("<C-o>j<Tab>", true, false, true)
		vim.api.nvim_feedkeys(keys, 'n', false)
	end
end
vim.keymap.set('i', '{<CR>', insert_parentheses('{', '}'))
vim.keymap.set('i', '[<CR>', insert_parentheses('[', ']'))
vim.keymap.set('i', '(<CR>', insert_parentheses('(', ')'))

local function ignore_autopairs(char)
	return function()
		local win = vim.api.nvim_get_current_win()
		local cursor = vim.api.nvim_win_get_cursor(win)
		local current_buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_text(current_buf, cursor[1]-1, cursor[2], cursor[1]-1, cursor[2], {char})
		local keys = vim.api.nvim_replace_termcodes("<Right><Tab>", true, false, true)
		vim.api.nvim_feedkeys(keys, 'i', false)
	end
end
vim.keymap.set('i', '"<Tab>', ignore_autopairs('"'))
vim.keymap.set('i', '\'<Tab>', ignore_autopairs('\''))
vim.keymap.set('i', '{<Tab>', ignore_autopairs('{'))
vim.keymap.set('i', '[<Tab>', ignore_autopairs('['))
vim.keymap.set('i', '(<Tab>', ignore_autopairs('('))
--
-- " Disable delimitmate for file types
-- let delimitMate_excluded_ft = "mail,txt,htmldjango"
--
-- " Wrap
vim.keymap.set('v', '(', '<ESC>`>a)<ESC>`<i(<ESC>`>lv`<l')
vim.keymap.set('v', '[', '<ESC>`>a]<ESC>`<i[<ESC>`>lv`<l')
vim.keymap.set('v', '{', '<ESC>`>a}<ESC>`<i{<ESC>`>lv`<l')
vim.keymap.set('v', '\'', '<ESC>`>a\'<ESC>`<i\'<ESC>`>lv`<l')
vim.keymap.set('v', '\\"', '<ESC>`>a"<ESC>`<i"<ESC>`>lv`<l')
vim.keymap.set('v', ';', '<ESC>`>a“<ESC>`<i„<ESC>`>lv`<l')

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

vim.keymap.set('n', 'gh', '<Cmd>nohlsearch<Cr><Cmd>lua require"toggleterm"<Cr><Cmd>1ToggleTerm<Cr>', {silent=true})
vim.keymap.set('n', '<F2>', '<Cmd>nohlsearch<Cr><Cmd>lua require"toggleterm"<Cr><Cmd>2ToggleTerm<Cr>', {silent=true})
vim.keymap.set('n', '<F3>', '<Cmd>nohlsearch<Cr><Cmd>lua require"toggleterm"<Cr><Cmd>3ToggleTerm<Cr>', {silent=true})
vim.keymap.set('t', '<C-w>', '<C-\\><C-n>', {silent=true})
vim.keymap.set('t', '<C-q>', function() vim.cmd('quit') end, {})
vim.keymap.set('t', '<C-PageUp>', '<C-\\><C-n><PageUp>', {silent=true})
vim.keymap.set('t', '<C-PageDown>', '<C-\\><C-n><PageDown>', {silent=true})

-- Save with ctrl+s
vim.keymap.set('n', '<C-S>', function() cmd("w") end)
vim.keymap.set('i', '<C-S>', function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false); cmd('w') end)

-- Git history
vim.keymap.set('n', '<leader>gh', ':0GlLog<CR>')
-- " :cexpr system('find . -name whatever.txt -printf "%p:1:1:%f\n"')

-- Close quick fix
vim.keymap.set('n', '<space>cc', ':cclose<CR>')
