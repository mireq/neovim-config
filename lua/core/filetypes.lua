-- pyton settings
vim.g.python_recommended_style = 0
vim.g.pyindent_open_paren = 'shiftwidth()'
vim.g.pyindent_continue = 'shiftwidth()'
vim.g.pyindent_close_paren = '-shiftwidth()'
-- vim.g.pyindent_disable_parentheses_indenting = 1
-- let g:rst_style=0
-- autocmd BufReadPre,BufNewFile,BufEnter *.py if exists('b:pymode_rope_project_root') | let g:pymode_rope_project_root=b:pymode_rope_project_root | else | let f=expand("%:p:h") . ";" | let rope_dir=finddir(".ropeproject", f) | if rope_dir == "" || rope_dir == expand("$HOME/.ropeproject") | let b:pymode_rope_project_root="" | else | let rope_absdir=fnamemodify(rope_dir, ':p:h:h') | let b:pymode_rope_project_root=rope_absdir | endif | let g:pymode_rope_project_root=b:pymode_rope_project_root | endif

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
	pattern = {'*.cpp', '*.h', '*.hpp', '*.php', '*.py', '*.css', '*.js', '*.html', '*.xhtml', '*.htm', '*.vue', '*.ts'},
	command = "match ExtraWhitespace /\\s\\+$\\| \\+\\ze\\t/",
})
vim.api.nvim_create_autocmd({"InsertEnter"}, {
	pattern = {'*.cpp', '*.h', '*.hpp', '*.php', '*.py', '*.css', '*.js', '*.html', '*.xhtml', '*.htm', '*.vue', '*.ts'},
	command = "match ExtraWhitespace /\\s\\+\\%#\\@<!$\\| \\+\\ze\\t\\%#\\@<!/",
})
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
	pattern = {'*.cpp', '*.h', '*.hpp', '*.php', '*.py', '*.css', '*.js', '*.html', '*.xhtml', '*.htm', '*.vue', '*.ts'},
	command = "match ExtraWhitespace /\\s\\+$\\| \\+\\ze\\t/",
})

-- HTML

vim.g.html_number_lines = 0
vim.g.use_xhtml = 1
vim.g.html_use_css = 1

vim.g.php_autocomment = 0
vim.g.PHP_autoformatcomment = 0



vim.cmd([[
func! ReformatHTML() range
	let content = join(getline(a:firstline, a:lastline), "\n")
	let baka = @a
	let baks = @/
	let @a = content
	silent execute 'new'
	silent execute 'normal "ap'
	silent execute 'set filetype=html'
	silent execute ':%s/^\s*//g'
	silent execute ':%s/\s*$//g'
	silent execute ':%s/<[^>]*>/\r&\r/g'
	silent execute ':%g/^$/d'
	silent execute 'normal 1G'
	silent execute 'normal VG'
	silent execute 'normal ='
	silent execute 'normal 1G'
	silent execute 'normal VG'
	silent execute 'normal "ay'
	silent execute ':bdelete!'
	silent execute a:firstline.','.a:lastline.'d'
	silent execute 'normal "aP'
	let @a = baka
	let @/ = baks
endfunc

command! -range=% ReformatHTML <line1>,<line2>call ReformatHTML()
]])

vim.cmd([[
func! EscapeHTML() range
	silent execute "silent! :'<,'>s/&/\\&amp;/g"
	silent execute "silent! :'<,'>s/</\\&lt;/g"
	silent execute "silent! :'<,'>s/>/\\&gt;/g"
endfunc
command! -range=% EscapeHTML <line1>,<line2>call EscapeHTML()
]])

-- C / C++

vim.api.nvim_create_autocmd({"Syntax"}, {
	pattern = {'cpp'},
	command = 'syn match cppFuncDef "::\\~\\?\\zs\\h\\w*\\ze([^)]*\\()\\s*\\(const\\)\\?\\)\\?$"',
})
vim.api.nvim_create_autocmd({"FileType"}, {
	pattern = {'c', 'cpp'},
	callback = function()
		vim.cmd('nmap <F5> "lYml[[kw"cye\'l')
		vim.cmd('nmap <F6> :set paste<CR>ma:let @n=@/<CR>"lp==:s/\\<virtual\\>\\s*//e<CR>:s/\\<static\\>\\s*//e<CR>:s/\\<explicit\\>\\s*//e<CR>:s/\\s*=\\s*[^,)]*//ge<CR>:let @/=@n<CR>\'ajf(b"cPa::<Esc>f;s<CR>{<CR>}<CR><Esc>kk:nohlsearch<CR>:set nopaste<CR>')
		vim.cmd('set foldmethod=indent')
		vim.cmd('set foldlevel=6')
	end
})

-- Python

--vim.api.nvim_create_autocmd({"BufNewFile"}, {
--	pattern = {'*.py'},
--	callback = function()
--		local win = vim.api.nvim_get_current_win()
--		local cursor = vim.api.nvim_win_get_cursor(win)
--		local current_buf = vim.api.nvim_get_current_buf()
--		vim.api.nvim_buf_set_text(current_buf, cursor[1]-1, cursor[2], cursor[1]-1, cursor[2], {"# -*- coding: utf-8 -*-", ""})
--	end
--})
vim.api.nvim_create_autocmd({"FileType"}, {
	pattern = {'py'},
	callback = function()
		vim.cmd([[
setlocal complete+=k
setlocal isk+=".,("
setlocal efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
		]])
	end
})
-- autocmd BufReadPre,BufNewFile,BufEnter *.py if exists('b:pymode_rope_project_root') | let g:pymode_rope_project_root=b:pymode_rope_project_root | else | let f=expand("%:p:h") . ";" | let rope_dir=finddir(".ropeproject", f) | if rope_dir == "" || rope_dir == expand("$HOME/.ropeproject") | let b:pymode_rope_project_root="" | else | let rope_absdir=fnamemodify(rope_dir, ':p:h:h') | let b:pymode_rope_project_root=rope_absdir | endif | let g:pymode_rope_project_root=b:pymode_rope_project_root | endif
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
	pattern = {'*.jinja', '*.html'},
	callback = function()
		vim.bo.filetype = "htmldjango"
	end
})

vim.api.nvim_create_autocmd({"FileType"}, {
	pattern = {'htmldjango'},
	callback = function(ev)
		vim.keymap.set('v', '\\tr', "<ESC>`>a' %}<ESC>`<i{{% trans '<ESC>", { buffer = ev.buf })
		vim.keymap.set('v', '\\tj', "<ESC>:set paste<CR>`>a{% endtrans %}<ESC>`<i{% trans %}<ESC>`>:set nopaste<CR>", { buffer = ev.buf })
	end
})


vim.api.nvim_create_autocmd({"FileType"}, {
	pattern = {'php'},
	callback = function(ev)
		vim.opt_local.smartindent = true
		vim.opt_local.indentexpr = nil
	end
})



vim.api.nvim_create_autocmd({"BufWritePre"}, {
	callback = function(ev)
		local dir = vim.fn.expand('<afile>:p:h')

		if dir:find('%l+://') == 1 then -- skip netrw
			return
		end

		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, 'p')
		end
	end
})

vim.g.python3_host_prog = "/usr/bin/python3"
