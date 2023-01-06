require("lazy").setup({
	'gpanders/editorconfig.nvim',
	{
		'weilbith/nvim-code-action-menu',
		cmd = 'CodeActionMenu',
		config = function()
			vim.g.code_action_menu_show_details = false
			vim.g.code_action_menu_show_diff = true
			vim.g.code_action_menu_show_action_kind = true
		end
	},
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'neovim/nvim-lspconfig',
			'quangnguyen30192/cmp-nvim-ultisnips',
			'SirVer/ultisnips',
			'honza/vim-snippets',
		},
		init = function()
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
		config = function()
			local cmp = require('cmp')
			local lspconfig = require('lspconfig')
			local cmp_nvim_lsp = require('cmp_nvim_lsp');
			cmp_nvim_lsp.setup()


			local opts = { noremap=true, silent=true }
			vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
			vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
			vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
			vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

			local on_attach = function(client, bufnr)
				vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

				local bufopts = { noremap=true, silent=true, buffer=bufnr }
				vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
				vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
				vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, bufopts)
				vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
				vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
				vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
				vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
				vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
				vim.keymap.set('n', '<space>wl', function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, bufopts)
				vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
				vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
				vim.keymap.set('n', '<space>ca', function() vim.cmd("CodeActionMenu") end, bufopts)
				vim.keymap.set('n', '<C-c>ro', function() vim.lsp.buf.code_action({ apply = true, context = { only = {"source.organizeImports"} } }) end, bufopts)
				vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
				vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
			end

			lspconfig['pylsp'].setup {
				on_attach = on_attach,
				settings = {
					pylsp = {
						plugins = {
							pylint = { enabled = true },
							autopep8 = { enabled = false },
							mccabe = { enabled = false },
							preload = { enabled = false },
							pyflakes = { enabled = false },
							pycodestyle = { enabled = false },
							yapf = { enabled = false },
						}
					}
				}
			}

			cmp.setup({
				sources = cmp.config.sources(
					{
						{
							name = 'buffer',
							option = {
								keyword_length = 5,
								get_bufnrs = function()
									local bufs = {}
									for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
										local byte_size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
										if byte_size < 1024 * 1024 then
											bufs[bufnr] = true
										end
									end
									return vim.tbl_keys(bufs)
								end
							}
						},
						{
							name = 'ultisnips'
						},
						{
							name = 'nvim_lsp'
						},
						{
							name = 'nvim_lsp_signature_help'
						},
					},
					{
						{
							name = 'path'
						},
					}
				),
				snippet = {
					expand = function(args)
						vim.fn["UltiSnips#Anon"](args.body)
					end,
				},
				window = {
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
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
				view = {
					--entries = "native"
				},
				experimental = {
					ghost_text = true,
					-- native_menu = true,
				},
			})

			vim.api.nvim_exec_autocmds("FileType", {})
		end,
	},
	{
		"FelikZ/ctrlp-py-matcher",
		keys = {
			{"<C-p>", "<cmd>CtrlP<CR>", desc="CtrlP"},
			{"<F3>", "<cmd>CtrlPBuffer<CR>", desc="CtrlP-buffers"},
		},
		dependencies = {
			'kien/ctrlp.vim',
		},
		config = function()
			--let g:ctrlp_use_caching = 0
			vim.g.ctrlp_cache_dir = vim.env.HOME .. '/.cache/ctrlp'
			vim.g.ctrlp_follow_symlinks = 1
			vim.g.ctrlp_working_path_mode = 'raw'
			vim.g.ctrlp_match_func = { match='pymatcher#PyMatch' }
			if vim.fn.executable('ag') then
				vim.g.ctrlp_user_command = 'ag %s --ignore-case --nogroup --nocolor --hidden --follow -U -p ~/.ignore -l -m 50000 -g ""'
			end
		end
	},
	{
		dir = vim.fn.stdpath("config") .. "/pack/colors/opt/killor",
		ft = 'python'
	},
	{
		"mbbill/undotree",
		keys = {
			{"<F7>", "<cmd>UndotreeToggle<CR>", desc="UndoTree"},
		},
		config = function()
			--let g:ctrlp_use_caching = 0
			vim.g.undotree_RelativeTimestamp = 1
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		config = function()
			require('lualine').setup {
				options = {
					icons_enabled = false,
					theme = 'powerline',
					component_separators = { left = '', right = ''},
					section_separators = { left = '', right = ''},
					disabled_filetypes = {
						statusline = {},
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					globalstatus = false,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
					}
				},
				sections = {
					lualine_a = {'mode'},
					lualine_b = {'branch', {'diagnostics', colored=true}},
					lualine_c = {{'filename', path=3}},
					lualine_x = {'encoding', 'fileformat', 'filetype'},
					lualine_y = {'progress'},
					lualine_z = {'location'}
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {'filename'},
					lualine_x = {'location'},
					lualine_y = {},
					lualine_z = {}
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {}
			}
		end
	},
	{
		'lewis6991/gitsigns.nvim',
		event = 'InsertEnter',
		config = function()
			require('gitsigns').setup {
				signs = {
					add          = { hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
					change       = { hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
					delete       = { hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
					topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
					changedelete = { hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
					untracked    = { hl = 'GitSignsAdd'   , text = '┆', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
				},
				signcolumn = false, -- Toggle with `:Gitsigns toggle_signs`
				numhl      = true,  -- Toggle with `:Gitsigns toggle_numhl`
				linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
				word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
				watch_gitdir = {
					interval = 1000,
					follow_files = true
				},
				attach_to_untracked = false,
				current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
					delay = 1000,
					ignore_whitespace = false,
				},
				current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil, -- Use default
				max_file_length = 40000, -- Disable if file is longer than this (in lines)
				preview_config = {
					-- Options passed to nvim_open_win
					border = 'single',
					style = 'minimal',
					relative = 'cursor',
					row = 0,
					col = 1
				},
				yadm = {
					enable = false
				},
			}
		end
	},
	{
		'pangloss/vim-javascript',
		config = function()
			vim.g.javascript_conceal = 1
			vim.g.javascript_conceal_function   = "∫"
			vim.g.javascript_conceal_null       = "Ø"
			vim.g.javascript_conceal_this       = "@"
			vim.g.javascript_conceal_return     = "❱"
			vim.g.javascript_conceal_undefined  = "¿"
			vim.g.javascript_conceal_NaN        = "Ṉ"
			vim.g.javascript_conceal_prototype  = "¶"
			vim.g.javascript_conceal_static     = "•"
			vim.g.javascript_conceal_super      = "Ω"
		end
	},
})
