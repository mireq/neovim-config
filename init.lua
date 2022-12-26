-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- "        _____
-- " ___   ____(_)______ ___
-- " __ | / /_  /__  __ `__ \
-- " __ |/ /_  / _  / / / / /
-- " _____/ /_/  /_/ /_/ /_/
-- "
-- "
-- " Maintainer: Miroslav Bendík
-- " Version: 0.3
-- " -------------------------------------------------------------
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Basic settings
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
local lazy = require("lazy")
local term = require("term")
local cmd = vim.cmd
-- " Disable help
vim.keymap.set('', '<F1>', '')
--
-- " Navigation with C-up / C-down
vim.keymap.set('', '<C-j>', 'gj')
vim.keymap.set('', '<C-k>', 'gk')
--
-- " Remap home
vim.keymap.set('', '<Home>', '^')
vim.keymap.set('i', '<Home>', '<C-O>^', {silent=true})
--
-- " Long lines are on same indent level
vim.o.breakindent = true
--
-- " Enable history
vim.o.history = 1000
--
-- " Enable : in keywords
vim.o.iskeyword = '@,~,48-57,_,192-255'
--
-- " Enable hidden buffers
vim.o.hidden = true
--
-- " Disable visual bell
vim.o.errorbells = false
vim.o.visualbell = false
--
-- " Set grep prorgram
vim.o.grepprg = 'grep -nH $*'
--
-- " Set visible lines / columns before and after cursor
vim.o.scrolloff = 3
vim.o.sidescroll = 5
--
-- " Default text width to 80 chars
vim.o.textwidth = 80
vim.o.colorcolumn = 80
vim.o.wrap = true
--
-- " Mouse
vim.o.mouse = 'a'
vim.o.mousehide = true
vim.o.mousemodel = 'popup'
--
-- " Integrate clipboard
vim.o.clipboard = 'unnamed,unnamedplus'
--
-- " Menu inside command line
vim.o.wildmenu = true
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Build
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- " Run make
-- map <F9> :make -j 2<CR>
vim.api.nvim_set_keymap('', '<F9>', ':make -j 2<CR>', {})
--
-- " Auto jump to first error
vim.o.cf = true
--
-- let &errorformat="%-GIn file included from %f:%l:%c\\,,%-GIn file included from %f:%l:%c:,%-Gfrom %f:%l\\,,-Gfrom %f:%l:%c\\,," . &errorformat
-- set errorformat+=%D%*\\a[%*\\d]:\ Entering\ directory\ `%f'
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Terminal
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vim.keymap.set('n', '<F2>', term.toggle)
vim.keymap.set('t', '<C-w>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:lua require("term").toggle()<CR>')

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Auto complete
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
vim.o.completeopt = 'menuone,menu'
--                   |       |
--                   |       + Display popup
--                   + Display when single option
--
-- " Hide help when cursor moved
-- autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
-- autocmd InsertLeave * if pumvisible() == 0|pclose|endif
--
-- " Set cursor shape
-- let &t_SI = "\<Esc>[6 q"
-- let &t_EI = "\<Esc>[2 q"
-- if v:version > 704 || v:version == 704 && has('patch687')
-- 	let &t_SR = "\<Esc>[4 q"
-- end
--
-- " Complete shortcuts
-- imap <C-Space> <C-X><C-I>
-- imap <Nul> <C-X><C-I>
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Plugins
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


lazy {
	map={'<F3>'},
	plugins={'vim-bufferlist'},
	post=function()
		vim.api.nvim_set_keymap('n', '<F3>', ':call BufferList()<CR>', {silent=true})
	end
}
lazy {
	event={{
		names={'InsertEnter'},
	}},
	plugins={'delimitMate', 'nvim-lspconfig', 'nvim-cmp', 'cmp-nvim-lsp', 'cmp-buffer', 'cmp-path', 'ultisnips', 'vim-snippets', 'cmp-nvim-ultisnips', 'cmp-nvim-lsp-signature-help'},
	--plugins={'delimitMate', 'nvim-lspconfig', 'nvim-cmp', 'cmp-nvim-lsp', 'cmp-buffer', 'cmp-path'},
	pre=function()
		vim.g.UltiSnipsExpandTrigger="<TAB>"
		vim.g.UltiSnipsJumpForwardTrigger="<TAB>"
		vim.g.UltiSnipsSnippetDirectories = {vim.fn.stdpath("config") .. '/UltiSnips', 'UltiSnips'}
		vim.g.UltiSnipsTriggerInVisualMode = 0
		vim.cmd([[
			function Ultisnips_get_current_python_class()
				let l:retval = ""
				let l:line_declaring_class = search('^class\s\+', 'bnW')
				if l:line_declaring_class != 0
					let l:nameline = getline(l:line_declaring_class)
					let l:classend = matchend(l:nameline, '\s*class\s\+')
					let l:classnameend = matchend(l:nameline, '\s*class\s\+[A-Za-z0-9_]\+')
					let l:retval = strpart(l:nameline, l:classend, l:classnameend-l:classend)
				endif
				return l:retval
			endfunction

			function Ultisnips_get_current_python_method()
				let l:retval = ""
				let l:line_declaring_method = search('\s*def\s\+', 'bnW')
				if l:line_declaring_method != 0
					let l:nameline = getline(l:line_declaring_method)
					let l:methodend = matchend(l:nameline, '\s*def\s\+')
					let l:methodnameend = matchend(l:nameline, '\s*def\s\+[A-Za-z0-9_]\+')
					let l:retval = strpart(l:nameline, l:methodend, l:methodnameend-l:methodend)
				endif
				return l:retval
			endfunction
		]])
	end,
	post=function()
		local cmp = require('cmp')
		local lspconfig = require('lspconfig')

		local cmp_nvim_lsp = require('cmp_nvim_lsp');
		cmp_nvim_lsp.setup()

		--local on_attach = function(client, bufnr)
		--	require('cmp_nvim_lsp')._on_insert_enter()
		--end

		--local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
		--lspconfig['jedi_language_server'].setup {
		--	capabilities = capabilities,
		--	on_attach = on_attach,
		--}
		--lspconfig['jedi_language_server'].manager.try_add()

		cmp.register_source('buffer', require('cmp_buffer'))
		cmp.register_source('path', require('cmp_path').new())
		cmp.register_source('ultisnips', require('cmp_nvim_ultisnips').create_source())
		cmp.register_source('nvim_lsp_signature_help', require('cmp_nvim_lsp_signature_help').new())
		vim.cmd("command! -nargs=0 CmpUltisnipsReloadSnippets lua require('cmp_nvim_ultisnips').reload_snippets()")
		cmp.setup({
			sources = cmp.config.sources(
				{
					{
						name = 'buffer',
						optioon = {
							keyword_length = 5,
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
								--local bufs = {}
								--for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
								--	local byte_size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
								--	if byte_size < 1024 * 1024 then
								--		bufs[bufnr] = true
								--	end
								--end
								--return vim.tbl_keys(bufs)
							end
						}
					},
					{
						name = 'ultisnips'
					},
					--{
					--	name = 'nvim_lsp'
					--},
					--{
					--	name = 'nvim_lsp_signature_help'
					--},
				},
				{
					{
						name = 'path'
					},
				}
			),
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert(),




formatting = {
    format = function(entry, vim_item)
        -- Kind icons
        vim_item.kind = string.format('%s %s', '', vim_item.kind) -- This concatonates the icons with the name of the item kind
        -- Source
        vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[LuaSnip]",
            nvim_lua = "[Lua]",
            latex_symbols = "[LaTeX]",
            path = "[Path]",
        })[entry.source.name]
        return vim_item
    end
},

experimental = {
    ghost_text = true,
    -- native_menu = true,
},


		})

		--require('cmp_nvim_lsp')._on_insert_enter()
		vim.api.nvim_exec_autocmds('BufEnter', {})
		vim.api.nvim_exec_autocmds('InsertEnter', {})
	end
}
lazy {
	event={{
		names={'FileType'},
		opts={pattern={"python"}}
	}},
	pre=function()
		vim.g.pymode_options = 0
		vim.g.pymode_rope = 1
		vim.g.pymode_rope_completion = 0
		vim.g.pymode_rope_complete_on_dot = 0
		vim.g.pymode_rope_completion_bind = '<C-Shift-Space>'
		vim.g.pymode_indent = 0
		vim.g.pymode_syntax = 0
		vim.g.pymode_lint = 0
		vim.g.pymode_folding = 0
		vim.g.pymode_rope_autoimport = 1
-- let g:pymode_debug = 1
	end,
	post=function()
		vim.api.nvim_exec_autocmds('FileType', {pattern="python"})
	end,
	plugins={'killor', 'python-mode'}
}
lazy {
	map={'<C-P>'},
	plugins={'ctrlp', "ctrlp-py-matcher"},
	pre=function()
-- 	let g:ctrlp_use_caching = 0
		vim.g.ctrlp_cache_dir = vim.env.HOME .. '/.cache/ctrlp'
		vim.g.ctrlp_follow_symlinks = 1
		vim.g.ctrlp_working_path_mode = 'raw'
		vim.g.ctrlp_match_func = { match='pymatcher#PyMatch' }
		if vim.fn.executable('ag') then
 			vim.g.ctrlp_user_command = 'ag %s --ignore-case --nogroup --nocolor --hidden --follow -U -p ~/.ignore -l -m 50000 -g ""'
		end
	end
}

--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Individual plugins
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- " YouCompleteMe
--
-- function s:init_YouCompleteMe()
-- 	let g:ycm_key_list_select_completion = ['<Down>']
-- 	let g:ycm_key_list_previous_completion = ['<Up>']
-- 	let g:ycm_confirm_extra_conf = 0
--
-- 	autocmd FileType python nmap <buffer> <F12> :YcmCompleter GoToDefinitionElseDeclaration<CR>
-- 	nmap <buffer> <F12> :YcmCompleter GoToDefinitionElseDeclaration<CR>
-- endfunction
--
-- call s:pluginPre("YouCompleteMe", function("s:init_YouCompleteMe"))
--
-- " ale
--
-- function s:init_ale()
-- 	let g:ale_lint_on_text_changed = "never"
-- 	let g:ale_lint_on_enter = 0
-- 	let g:ale_lint_on_filetype_changed = 0
-- 	let g:ale_lint_on_save = 1
-- 	let g:ale_lint_on_insert_leave = 0
-- 	let g:ale_java_javac_classpath = '/opt/android-sdk/platforms/android-31/android.jar'
-- endfunction
--
-- call s:pluginPre("ale", function("s:init_ale"))
--
--
-- " ctrlp
--
-- function s:init_ctrlp()
-- 	unmap <c-p>
-- 	"let g:ctrlp_use_caching = 0
-- 	let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
-- 	let g:ctrlp_follow_symlinks = 1
-- 	let g:ctrlp_working_path_mode = 'raw'
-- 	if executable('ag')
-- 		let g:ctrlp_user_command = 'ag %s --ignore-case --nogroup --nocolor --hidden --follow
-- 			\ -U -p ~/.ignore
-- 			\ -l -m 50000
-- 			\ -g ""'
-- 	endif
-- endfunction
--
-- function s:init_ctrlp_py_matcher()
-- 	let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
-- endfunction
--
-- function s:init_ctrlp_py_matcher_post()
-- 	:CtrlP
-- endfunction
--
--
-- call s:pluginPre("ctrlp", function("s:init_ctrlp"))
-- call s:pluginPre("ctrlp-py-matcher", function("s:init_ctrlp_py_matcher"))
-- call s:pluginPost("ctrlp-py-matcher", function("s:init_ctrlp_py_matcher_post"))
--
--
-- " gundo
--
-- function s:init_gundo()
-- 	nunmap <F7>
-- 	let g:gundo_prefer_python3=1
-- endfunction
--
-- function s:init_gundo_post()
-- 	nmap <F7> :GundoToggle<CR>
-- 	"call feedkeys("\<F7>")
-- 	:GundoToggle
-- endfunction
--
-- call s:pluginPre("gundo", function("s:init_gundo"))
-- call s:pluginPost("gundo", function("s:init_gundo_post"))
--
--
-- " powerline
--
-- set rtp+=$HOME/.vim/pack/plugins/start/powerline/powerline/bindings/vim
--
--
-- " ultisnips
--
--
--
-- " tagbar
--
-- function s:init_tagbar()
-- 	nunmap <F11>
-- endfunction
--
-- function s:init_tagbar_post()
-- 	nmap <F11> :TagbarToggle<CR>
-- 	:TagbarToggle
-- endfunction
--
-- call s:pluginPre("tagbar", function("s:init_tagbar"))
-- call s:pluginPost("tagbar", function("s:init_tagbar_post"))
--
--
-- " indent-guides
--
-- let g:indent_guides_auto_colors = 0
-- let g:indent_guides_enable_on_vim_startup = 1
-- let g:indent_guides_exclude_filetypes = ['help', 'nerdtree', 'project']
-- let g:indent_guides_space_guides = 0
-- let g:indent_guides_start_level = 1
-- let g:indent_guides_indent_levels = 10
--
--
-- " signify
--
-- function s:init_signify_post()
-- 	:SignifyEnable
-- endfunction
--
-- call s:pluginPost("signify", function("s:init_signify_post"))
--
--
-- " jsavascript
--
-- function s:init_javascript()
-- 	let g:javascript_conceal = 1
-- 	let g:javascript_conceal_function   = "∫"
-- 	let g:javascript_conceal_null       = "Ø"
-- 	let g:javascript_conceal_this       = "@"
-- 	let g:javascript_conceal_return     = "❱"
-- 	let g:javascript_conceal_undefined  = "¿"
-- 	let g:javascript_conceal_NaN        = "Ṉ"
-- 	let g:javascript_conceal_prototype  = "¶"
-- 	let g:javascript_conceal_static     = "•"
-- 	let g:javascript_conceal_super      = "Ω"
-- endfunction
--
--
-- call s:pluginPre("vim-javascript", function("s:init_javascript"))
--
--
-- "call s:loadPlugin("ultisnips")
-- "call s:loadPlugin("vim-snippets")
--
-- autocmd InsertEnter * ++once call s:loadPlugin("ultisnips")
-- autocmd InsertEnter * ++once call s:loadPlugin("vim-snippets")
-- autocmd InsertEnter * ++once call s:loadPlugin("YouCompleteMe")
-- nmap <F12> :call <SID>loadPlugin("YouCompleteMe")<CR>:YcmCompleter GoToDefinitionElseDeclaration<CR>
-- autocmd FileType javascript,python,java ++once call s:loadPlugin("ale")
-- map <c-p> :call <SID>loadPlugin("ctrlp")<CR>:call <SID>loadPlugin("ctrlp-py-matcher")<CR>
-- autocmd FileType html,htmldjango ++once call s:loadPlugin("emmet-vim")
-- nmap <F7> :call <SID>loadPlugin("gundo")<CR>
-- autocmd InsertEnter * ++once call s:loadPlugin("nerdcommenter")
-- map <F3> :call <SID>loadPlugin("vim-bufferlist")<CR>
-- nmap <F11> :call <SID>loadPlugin("tagbar")<CR>
-- autocmd FileType css,scss ++once call s:loadPlugin("vim-css3-syntax")
-- autocmd InsertEnter * ++once call s:loadPlugin("vim-signify")
-- autocmd FileType javascript ++once call s:loadPlugin("vim-javascript")
-- autocmd FileType po ++once call s:loadPlugin("po")
-- autocmd FileType glsl ++once call s:loadPlugin("vim-glsl")
--
--
-- filetype indent on
-- filetype plugin on


--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Saving
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- " Backup
vim.o.backup = true
vim.o.backupdir = vim.fn.stdpath("data") .. "/backup//"

--
-- " Tmp directory
vim.o.directory = vim.fn.stdpath("data") .. "/swap//"
--
-- " Ask before close
vim.o.confirm = true
--
-- " Viminfo
-- set viminfo='50,\"500
-- "            |    |
-- "            |    + Maximum number of files for each register
-- "            + Save max 50 files
--
-- " Persistent undo
vim.o.undodir = vim.fn.stdpath("data") .. "/undo//"
vim.o.undofile = true
vim.o.undolevels = 2048
vim.o.undoreload = 65538

-- " Reload file, preserve history
-- command! Reload %d|r|1d
--
-- " Save with ctrl+s
vim.keymap.set('n', '<C-S>', function() cmd("w") end)
vim.keymap.set('i', '<C-S>', function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', false); cmd("w") end)
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Formating
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- Prevent auto indenting while typing

vim.o.formatoptions = 'croq1'
--                     |||||
--                     ||||+ Not break lines in insert mode
--                     |||+ Formatting with gq
--                     ||+ Insert comment leader after 'o'
--                     |+ Insert comment leader after <Enter>
--                     + Auto wrap comments using textwidth
--
-- " Wrap on end
vim.o.wrapmargin = 0
vim.o.linebreak = true
--
-- " Copy indent structure
vim.o.copyindent = true
vim.o.preserveindent = true
--
-- " Round to tabs
vim.o.shiftround = true
--
-- " Use tabs
vim.o.tabstop = 3
vim.o.shiftwidth = 3
--
-- " Indent for language
vim.o.smartindent = true

-- " Adjust indent
vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave"}, {
	callback = function()
		vim.keymap.set('x', '<Tab>', '>gv')
		vim.keymap.set('x', '<BS>', '<gv')
	end
})
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Display
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- " Enable line number display
vim.o.number = true
--
-- " Hide conceal chars
vim.o.conceallevel = 2

-- " Don't redraw while executing macro
vim.o.lazyredraw = true
--
-- " Show title in terminal window
vim.o.title = true
--
-- " Show matching brackets
vim.o.showmatch = true
--
-- " Highlidhgt search
vim.o.hlsearch = true
vim.o.incsearch = true

-- " Disable toolbars
-- if has("gui_running")
-- 	set guioptions-=T
-- endif
--
-- " Enable syntax
vim.o.syntax = true

-- " Whitespace symbols
if vim.fn.has('multi_byte') then
	vim.o.fillchars = 'stl: ,stlnc: ,vert:┆,fold:-,diff:-'
--	"set lcs=tab:\⁝\ ,trail:•,extends:>,precedes:<,nbsp:¤"
	vim.o.lcs = 'tab:┆ ,extends:>,precedes:<,trail:•,nbsp:¤'
	vim.o.sbr = '…'
	--let &sbr = nr2char(8618).' '
else
	vim.o.fillchars = 'stl: ,stlnc: ,vert:|,fold:-,diff:-'
	vim.o.lcs = 'tab:> ,extends:>,precedes:<,trail:-'
	vim.o.sbr = '+++'
end

vim.o.list = true

vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "WinEnter", "CmdwinEnter"}, {
	callback = function()
		if (vim.o.previewwindow or vim.fn.bufname() == "__BUFFERLIST__") then
			vim.opt_local.list = false
		end
	end
})


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

cmd 'colorscheme mirec'

--
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
		local keys = vim.api.nvim_replace_termcodes("<C-o>k<Tab>", true, false, true)
		vim.api.nvim_feedkeys(keys, 'n', false)
	end
end
vim.keymap.set('i', '{<CR>', insert_parentheses('{', '}'))
vim.keymap.set('i', '[<CR>', insert_parentheses('[', ']'))
vim.keymap.set('i', '(<CR>', insert_parentheses('(', ')'))
--
-- " Disable delimitmate for file types
-- let delimitMate_excluded_ft = "mail,txt,htmldjango"
--
-- " Wrap
vim.keymap.set('v', '(', '<ESC>`>a)<ESC>`<i(<ESC>`>lv`<l')
vim.keymap.set('v', '[', '<ESC>`>a]<ESC>`<i[<ESC>`>lv`<l')
vim.keymap.set('v', '{', '<ESC>`>a}<ESC>`<i{<ESC>`>lv`<l')
vim.keymap.set('v', '\'', '<ESC>`>a\'<ESC>`<i\'<ESC>`>lv`<l')
vim.keymap.set('v', '"', '<ESC>`>a"<ESC>`<i"<ESC>`>lv`<l')
vim.keymap.set('v', ';', '<ESC>`>a“<ESC>`<i„<ESC>`>lv`<l')
--
-- " Reverse chars
-- vmap \rv c<C-O>:set revins<CR><C-R>"<Esc>:set norevins<CR>
--
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Settings for file types
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- " HTML
-- let html_number_lines = 0
-- let use_xhtml = 1
-- let html_use_css = 1
--
-- func! ReformatHTML() range
-- 	let content = join(getline(a:firstline, a:lastline), "\n")
-- 	let baka = @a
-- 	let baks = @/
-- 	let @a = content
-- 	silent execute 'new'
-- 	silent execute 'normal "ap'
-- 	silent execute 'set filetype=html'
-- 	silent execute ':%s/^\s*//g'
-- 	silent execute ':%s/\s*$//g'
-- 	silent execute ':%s/<[^>]*>/\r&\r/g'
-- 	silent execute ':%g/^$/d'
-- 	silent execute 'normal 1G'
-- 	silent execute 'normal VG'
-- 	silent execute 'normal ='
-- 	silent execute 'normal 1G'
-- 	silent execute 'normal VG'
-- 	silent execute 'normal "ay'
-- 	silent execute ':bdelete!'
-- 	silent execute a:firstline.','.a:lastline.'d'
-- 	silent execute 'normal "aP'
-- 	let @a = baka
-- 	let @/ = baks
-- endfunc
--
-- command! -range=% ReformatHTML <line1>,<line2>call ReformatHTML()
--
--
-- " cpp
-- function! EnhanceCppSyntax()
-- 	syn match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$"
-- endfunction
-- autocmd Syntax cpp call EnhanceCppSyntax()
-- autocmd FileType c,cpp nmap <F5> "lYml[[kw"cye'l
-- autocmd FileType c,cpp nmap <F6> :set paste<CR>ma:let @n=@/<CR>"lp==:s/\<virtual\>\s*//e<CR>:s/\<static\>\s*//e<CR>:s/\<explicit\>\s*//e<CR>:s/\s*=\s*[^,)]*//ge<CR>:let @/=@n<CR>'ajf(b"cPa::<Esc>f;s<CR>{<CR>}<CR><Esc>kk:nohlsearch<CR>:set nopaste<CR>
-- autocmd FileType c,cpp set foldmethod=indent
-- autocmd FileType c,cpp set foldlevel=6
--
-- " python
-- autocmd BufNewFile *.py execute "set paste" | execute "normal i# -*- coding: utf-8 -*-\r" | execute "set nopaste"
-- autocmd FileType python set completeopt=menuone,menu,preview
-- autocmd FileType python setlocal complete+=k
-- autocmd FileType python setlocal isk+=".,("
-- autocmd BufRead *.py setlocal makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
-- autocmd BufRead *.py setlocal efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
-- autocmd BufReadPre,BufNewFile,BufEnter *.py if exists('b:pymode_rope_project_root') | let g:pymode_rope_project_root=b:pymode_rope_project_root | else | let f=expand("%:p:h") . ";" | let rope_dir=finddir(".ropeproject", f) | if rope_dir == "" || rope_dir == expand("$HOME/.ropeproject") | let b:pymode_rope_project_root="" | else | let rope_absdir=fnamemodify(rope_dir, ':p:h:h') | let b:pymode_rope_project_root=rope_absdir | endif | let g:pymode_rope_project_root=b:pymode_rope_project_root | endif
-- au BufNewFile,BufRead *.jinja set ft=htmldjango
-- au BufNewFile,BufRead *.vert,*.tesc,*.tese,*.glsl,*.geom,*.frag,*.comp set filetype=glsl
--
-- " Fix python identation
--
-- autocmd BufReadPre,BufNewFile,BufEnter *.py if exists('b:pymode_rope_project_root') | let g:pymode_rope_project_root=b:pymode_rope_project_root | else | let f=expand("%:p:h") . ";" | let rope_dir=finddir(".ropeproject", f) | if rope_dir == "" || rope_dir == expand("$HOME/.ropeproject") | let b:pymode_rope_project_root="" | else | let rope_absdir=fnamemodify(rope_dir, ':p:h:h') | let b:pymode_rope_project_root=rope_absdir | endif | let g:pymode_rope_project_root=b:pymode_rope_project_root | endif

vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile", "BufEnter"}, {
	pattern = {'*.py'},
	callback = function()
		if vim.b.pymode_rope_project_root == nil then
			local filename = vim.fn.expand("%:p:h") .. ';'
			local rope_dir = vim.fn.finddir('.ropeproject', filename)
			if rope_dir == '' then
				rope_dir = vim.env['HOME'] .. '/.ropeproject'
				vim.b.pymode_rope_project_root = ''
			else
				vim.b.pymode_rope_project_root = vim.fn.fnamemodify(rope_dir, ':p:h:h')
			end
		end
		vim.g.pymode_rope_project_root = vim.b.pymode_rope_project_root
	end
})
vim.g.python_recommended_style = 0
vim.g.pyindent_open_paren = 'shiftwidth()'
vim.g.pyindent_continue = 'shiftwidth()'
vim.g.pyindent_close_paren = '-shiftwidth()'
-- let g:rst_style=0
--
-- " javascript
-- autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
-- autocmd FileType javascript set completefunc=javascriptcomplete#CompleteJS
--
-- " html
-- autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
-- autocmd FileType html set completefunc=htmlcomplete#CompleteTags
-- autocmd FileType html set filetype=htmldjango
-- autocmd FileType htmldjango vmap \tr <ESC>`>a'' %}<ESC>`<i{{% trans ''<ESC>
-- autocmd FileType htmldjango vmap \tj <ESC>:set paste<CR>`>a{% endtrans %}<ESC>`<i{% trans %}<ESC>`>:set nopaste<CR>
--
-- " css
-- autocmd FileType css set omnifunc=csscomplete#CompleteCSS
-- autocmd FileType css set completefunc=csscomplete#CompleteCSS
--
-- " common completion
-- autocmd FileType c,cpp,java,php,python,html,css,javascript imap <C-Space> <C-X><C-O>
-- autocmd FileType c,cpp,java,php,python,html,css,javascript imap <Nul> <C-X><C-O>
--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Utility
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- " Convert vimrc to HTML
-- " Link to section: *> Section name
-- " Section: => Section name
-- function! VimrcTOHtml()
-- 	TOhtml
-- 	try
-- 		silent exe '%s/&quot;\(\s\+\)\*&gt; \(.\+\)</"\1<a href="#\2" style="color: #bdf">\2<\/a></g'
-- 	catch
-- 	endtry
--
-- 	try
-- 		silent exe '%s/&quot;\(\s\+\)=&gt; \(.\+\)</"\1<a name="\2" style="color: #fff">\2<\/a></g'
-- 	catch
-- 	endtry
--
-- 	exe ":write!"
-- 	exe ":bd"
-- endfunction
--
-- function! ReformatXml()
-- 	%!xmllint --format --recover --encode utf-8 - 2>/dev/null
-- endfunction
-- command! ReformatXml call ReformatXml()
--
-- function! ReplaceDiacritic()
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ľ/\\&#317;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Š/\\&#352;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ť/\\&#356;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ž/\\&#381;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ľ/\\&#318;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/š/\\&#353;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ť/\\&#357;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ž/\\&#382;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ŕ/\\&#340;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ĺ/\\&#313;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Č/\\&#268;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ě/\\&#282;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ď/\\&#270;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ň/\\&#327;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ř/\\&#344;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ů/\\&#366;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ŕ/\\&#341;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ľ/\\&#314;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/č/\\&#269;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ě/\\&#283;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ď/\\&#271;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ň/\\&#328;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ř/\\&#345;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ô/\\&#244;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ô/\\&#212;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ý/\\&#221;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ý/\\&#253;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Á/\\&Aacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/á/\\&aacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/É/\\&Eacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/é/\\&eacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Í/\\&Iacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/í/\\&iacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ó/\\&Oacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ó/\\&oacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/Ú/\\&Uacute;/g"
-- 	execute "silent! " . a:firstline . "," . a:lastline . "s/ú/\\&uacute;/g"
-- endfunction
--
-- function! MailSettings()
-- 	setlocal textwidth=0
-- 	setlocal comments+=b:--
-- 	setlocal formatoptions+=tcqan
-- 	" setlocal nosi nocin
-- 	" setlocal comments=n:>
-- 	" setlocal equalprg=fmt
-- 	" Odstránenie starých podpisov
-- 	" autocmd BufReadPost /tmp/mutt* :g/^> -- $/.;/^$/-d
-- 	try | :%s/>> -- $\n\(>> .*\n\)*// | catch | endtry
-- 	try | :%s/> -- $\n\(> .*\n\)*// | catch | endtry
-- 	" Zmena zlého formátu citácií
-- 	try | :%s/^> >/>> / | catch | endtry
-- 	try | :%s/^>> >/>>> / | catch | endtry
-- 	try | :%s/^>>> >/>>>> / | catch | endtry
-- 	" Odstránenie prebytočných riadkov
-- 	try | %s/\(^>\n\)\{2,}/>\r/g | catch | endtry
-- 	" Presun nad pätičku
-- 	normal 0G
-- 	normal 8k
--
-- 	setlocal ignorecase infercase
-- 	"setlocal wrap
-- 	setlocal nocp
-- 	let @/ = '^>[ \t]*$'
--
-- 	let b:url_nr = 1
-- 	vmap <buffer> . c> [[...]<Esc>
-- 	" insert mode mappings
-- 	imap <buffer> <C-l> <ESC>:call MailInsertURL()<CR>
-- 	"map <buffer> <F2> :%g/^>\( \?>\)/d<CR>
-- 	"map <buffer> <F3> :%g/^>\( \?>\)\{2}/d<CR>
-- 	"map <buffer> <F4> :%g/^>\( \?>\)\{3}/d<CR>
-- 	map <buffer> <leader>q :%s/=\(\x\x\)/\=nr2char(str2nr(submatch(1),16))/g<CR>
--
-- 	function! MailInsertURL()
-- 		set paste
-- 		let l:url = input("URL: ")
-- 		execute "normal a[".b:url_nr."]\<Esc>mzG"
-- 		try
-- 			execute "?^-- $"
-- 			if b:url_nr == 1
-- 				normal 0k
-- 			else
-- 				normal k
-- 			endif
-- 		catch
-- 		endtry
-- 		execute "normal o[".b:url_nr."] ".l:url."\<Esc>`za"
-- 		let b:url_nr += 1
-- 		set nopaste
-- 	endfunction
--
-- endfunction
--
-- au BufReadPost * if getfsize(bufname("%")) > 512*1024 | set syntax= | endif
--
-- "au Syntax * RainbowParenthesesLoadRound
-- "au Syntax * RainbowParenthesesLoadSquare
-- "au Syntax * RainbowParenthesesLoadBraces
-- "let g:rbpt_colorpairs = [
-- "      \ ['brown',       'RoyalBlue3'],
-- "      \ ['Darkblue',    'SeaGreen3'],
-- "      \ ['darkgray',    'DarkOrchid3'],
-- "      \ ['darkgreen',   'firebrick3'],
-- "      \ ['darkcyan',    'RoyalBlue3'],
-- "      \ ['darkred',     'SeaGreen3'],
-- "      \ ['darkmagenta', 'DarkOrchid3'],
-- "      \ ['brown',       'firebrick3'],
-- "      \ ['gray',        'RoyalBlue3'],
-- "      \ ['196',         '#ff0000'],
-- "      \ ['200',         '#ff00df'],
-- "      \ ['39',          '#00afff'],
-- "      \ ['87',          '#5fffff'],
-- "      \ ['118',         '#87ff00'],
-- "      \ ['229',         '#ffffaf'],
-- "      \ ['255',         '#eeeeee'],
-- "      \ ]
--
-- function! CleanCSS()
-- 	try
-- 		silent execute "%s/\\t\\+$//g"
-- 	catch
-- 	endtry
--
-- 	try
-- 		silent execute "%s/[ ]\\+$//g"
-- 	catch
-- 	endtry
--
-- 	try
-- 		silent execute "%s/\\([^ ]\\){/\\1 {/g"
-- 	catch
-- 	endtry
--
-- 	try
-- 		silent execute "%s/:\\([^ ]\\)\\(.*\\);/: \\1\\2;/"
-- 	catch
-- 	endtry
-- endfunction
--
-- function! WriteCreatingDirs()
-- 	execute 'normal !mkdir -p %:h'
-- 	execute 'normal write'
-- endfunction
-- command W call WriteCreatingDirs()
--
-- let c_no_curly_error = 1
--
--
-- function s:MkNonExDir(file, buf)
-- 	if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
-- 		let dir=fnamemodify(a:file, ':h')
-- 		if !isdirectory(dir)
-- 			call mkdir(dir, 'p')
-- 		endif
-- 	endif
-- endfunction
-- augroup BWCCreateDir
-- 	autocmd!
-- 	autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
-- augroup END
--
--
-- " Protect large files from sourcing and other overhead.
-- " Files become read only
-- if !exists("my_auto_commands_loaded")
--   let my_auto_commands_loaded = 1
--   " Large files are > 10M
--   " Set options:
--   " eventignore+=FileType (no syntax highlighting etc
--   " assumes FileType always on)
--   " noswapfile (save copy of file)
--   " bufhidden=unload (save memory when other file is viewed)
--   " buftype=nowrite (file is read-only)
--   " undolevels=-1 (no undo possible)
--   let g:LargeFile = 1024 * 1024
--   augroup LargeFile
--     autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
--     augroup END
--  endif
--
-- function! HTMLTextHighlight()
-- 	syntax off
-- 	syntax region comment start=/</ end=/>/
-- 	syntax region comment start=/</ end=/>/
-- 	syntax region comment start=/{%/ end=/%}/
-- 	syntax region comment start=/{{/ end=/}}/
-- 	syntax region comment start=/{#/ end=/#}/
-- 	syntax match Title /{%\s*\(end\)\?trans[^%]*%}/
-- endfunction
--
-- function! ChangeTimetrackPrompt()
-- 	let git_dir=system("cd -- ".expand("%:p:h::S")." && git rev-parse --absolute-git-dir")->split('\n', 1)[0]
-- endfunction
--
--
-- map <buffer> <leader>gh :0GlLog<CR>
--
-- " :cexpr system('find . -name whatever.txt -printf "%p:1:1:%f\n"')
