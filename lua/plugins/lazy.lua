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
			'onsails/lspkind.nvim',
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
			local types = require("cmp.types")
			local lspconfig = require('lspconfig')
			local cmp_nvim_lsp = require('cmp_nvim_lsp');
			cmp_nvim_lsp.setup()
			local capabiliies = cmp_nvim_lsp.default_capabilities();


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
				--vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
				vim.keymap.set('n', '<C-c>ro', function() vim.lsp.buf.code_action({ apply = true, context = { only = {"source.organizeImports"} } }) end, bufopts)
				vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
				vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
			end

			-- display text completion at end of file
			local function deprioritize_text(entry1, entry2)
				if entry1:get_kind() == types.lsp.CompletionItemKind.Text then return false end
				if entry2:get_kind() == types.lsp.CompletionItemKind.Text then return true end
			end

			lspconfig['pylsp'].setup {
				on_attach = on_attach,
				capabilities = capabilities,
				flags = {
					debounce_text_changes = 500
				},
				root_dir = function(fname)
					local root_files = {
						'.ropeproject',
					}
					return lspconfig.util.root_pattern(unpack(root_files))(fname) or lspconfig.util.find_git_ancestor(fname)
				end,
				settings = {
					pylsp = {
						plugins = {
							--pylint = { enabled = true, args = {'--init-hook="try: import pylint_venv\nexcept ImportError: pass\nelse: pylint_venv.inithook()"', "aaa"} },
							--pylint = { enabled = true, args = {'--init-hook="__import__(\'pylint_venv\').inithook()"'} },
							pylint = { enabled = true },
							autopep8 = { enabled = false },
							mccabe = { enabled = false },
							preload = { enabled = false },
							pyflakes = { enabled = false },
							pycodestyle = { enabled = false },
							yapf = { enabled = false },
						},

					}
				}
			}

			cmp.setup({
				sources = cmp.config.sources(
					{
						{
							name = 'ultisnips'
						},
						{
							name = 'nvim_lsp'
						},
						{
							name = 'nvim_lsp_signature_help'
						},
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
					completion = {
						--winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
						col_offset = -3,
						side_padding = 0,
					}
				},
				mapping = cmp.mapping.preset.insert({
					['<C-k>'] = cmp.mapping.scroll_docs(-4),
					['<C-j>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					--['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. (strings[1] or "") .. " "
						--kind.kind = '▍' -- instead of symbol
						kind.menu = " " .. (strings[2] or "")
						return kind
					end
				},
				view = {
					--entries = "native"
				},
				experimental = {
					ghost_text = true,
					-- native_menu = true,
				},
				sorting = {
					priority_weight = 2,
					comparators = {
						deprioritize_text,
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						-- cmp.config.compare.scopes,
						cmp.config.compare.score,
						cmp.config.compare.recently_used,
						cmp.config.compare.locality,
						cmp.config.compare.kind,
						-- cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
			})

			vim.api.nvim_exec_autocmds("FileType", { group = 'lspconfig', modeline = false })
			vim.diagnostic.config({update_in_insert = false })
			vim.lsp.set_log_level("debug")

			vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
				vim.lsp.diagnostic.on_publish_diagnostics, {
					signs = true,
					underline = false,
					virtual_text = true,
					show_diagnostic_autocmds = {'PostSave'},
					diagnostic_delay = 1000
				}
			)

			vim.cmd("au! UltiSnips_AutoTrigger")
		end,
	},
	{
		"FelikZ/ctrlp-py-matcher",
		keys = {
			{"<C-p>", "<cmd>CtrlP<CR>", desc="CtrlP"},
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
	{
		'mattn/emmet-vim',
		filetype = {'html', 'htmldjango'}
	},
	{
		'vim-scripts/po.vim--Jelenak',
		filetype = {'po'}
	},
	{
		'tikhomirov/vim-glsl',
		filetype = {'glsl'}
	},
	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		config = function()
			require("nvim-autopairs").setup {}
		end
	},
	{
		'tpope/vim-fugitive',
		event = 'InsertEnter',
		cmd = {'Git'},
	},
	{
		"roblillack/vim-bufferlist",
		keys = {
			{"<F3>", "<cmd>call BufferList()<CR>", desc="Buffer list"},
		},
	},
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim'
		},
		keys = {
			{"<leader>fg", "<cmd>Telescope live_grep<cr>", desc="Telescope live_grep"},
		},
		cmd = {'Telescope'},
		config = function()
			require('telescope').setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"-L",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
					prompt_prefix = "   ",
					selection_caret = "",
					entry_prefix = "",
					initial_mode = "insert",
					selection_strategy = "reset",
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.94,
						height = 0.90,
						preview_cutoff = 120,
					},
					results_title = false,
					file_sorter = require("telescope.sorters").get_fuzzy_file,
					file_ignore_patterns = { "node_modules" },
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
					path_display = { "truncate" },
					winblend = 0,
					border = {},
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					color_devicons = true,
					file_previewer = require("telescope.previewers").vim_buffer_cat.new,
					grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
					qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
					buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
					mappings = {
						n = { ["q"] = require("telescope.actions").close },
					},
				},

				extensions_list = {"themes", "terms"},
			})
		end
	},
	{
		'akinsho/toggleterm.nvim',
		cmd = {'ToggleTerm', 'TermExec'},
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<F2>]],
				direction = 'tab',
				on_create = function(t)
					vim.keymap.set('n', '<C-q>', '<Cmd>exe v:count1 . "ToggleTerm"<CR>', { buffer = t.bufnr })
				end,
			})
		end
	},
	{
		dir = vim.fn.stdpath("config") .. "/pack/colors/opt/mirec",
	},
}, {install={colorscheme={"mirec"}}})
