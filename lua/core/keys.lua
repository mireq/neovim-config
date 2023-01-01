local term = require("term")

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
