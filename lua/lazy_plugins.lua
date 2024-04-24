local snippet_engine = 'luasnip' -- luasnip or ultisnips

local ultisnips_nvim_cmp_deps = {
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-cmdline',
	'hrsh7th/cmp-nvim-lsp-signature-help',
	'neovim/nvim-lspconfig',
	'onsails/lspkind.nvim',
	'quangnguyen30192/cmp-nvim-ultisnips',
	'SirVer/ultisnips',
	'honza/vim-snippets',
}
local luasnip_nvim_cmp_deps = {
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-cmdline',
	'hrsh7th/cmp-nvim-lsp-signature-help',
	'neovim/nvim-lspconfig',
	'onsails/lspkind.nvim',
	'L3MON4D3/LuaSnip',
	'saadparwaiz1/cmp_luasnip'
}
local nvim_cmp_deps = nil;
if snippet_engine == 'ultisnips' then
	nvim_cmp_deps = ultisnips_nvim_cmp_deps
else
	nvim_cmp_deps = luasnip_nvim_cmp_deps
end


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
		dependencies = nvim_cmp_deps,
		config = function()
			local cmp = require('cmp')
			local types = require("cmp.types")
			local lspconfig = require('lspconfig')
			local lspconfig_util = require 'lspconfig.util'
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

				client.server_capabilities.semanticTokensProvider = nil
			end

			local function get_kind_priority(kind)
				local priority = 100
				if kind == types.lsp.CompletionItemKind.Text then
					priority = 0
				end
				if kind == types.lsp.CompletionItemKind.Snippet then
					priority = 50
				end
				return priority
			end

			-- display text completion at end of file
			local function set_priority(entry1, entry2)
				--local f = io.open("/tmp/e.txt", "w")
				--f:write(vim.inspect(entry1))
				--f:close()
				local entry_kind_1 = entry1:get_kind()
				local entry_kind_2 = entry2:get_kind()
				local entry1_priority = get_kind_priority(entry_kind_1)
				local entry2_priority = get_kind_priority(entry_kind_2)
				if entry1_priority == entry2_priority then
					return nil
				else
					return entry1_priority > entry2_priority
				end
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
							pylint = { enabled = true, args={'--init-hook="exec(\'try: import pylint_venv\\nexcept ImportError: pass\\nelse: pylint_venv.inithook()\')"'} },
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

			local ts_plugin_path = vim.env.HOME .. '/lib64/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin'
			lspconfig.tsserver.setup {
				init_options = {
					plugins = {
						{
							name = '@vue/typescript-plugin',
							location = ts_plugin_path,
							languages = { 'vue' },
						},
					},
				},
				flags = {
					debounce_text_changes = 500
				},
				on_attach = on_attach,
				filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
			}

			lspconfig.volar.setup {
				flags = {
					debounce_text_changes = 500
				},
				on_attach = on_attach,
			}

			local insert_mapping = cmp.mapping.preset.insert({
				['<C-u>'] = cmp.mapping.scroll_docs(-4),
				['<C-d>'] = cmp.mapping.scroll_docs(4),
				['<C-Space>'] = cmp.mapping.complete(),
				['<C-j>'] = cmp.mapping.confirm({ select = true }),
				--['<C-e>'] = cmp.mapping.abort(),
				--['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			})
			insert_mapping['<C-E>'] = nil

			cmp.setup({
				sources = cmp.config.sources(
					{
						{
							name = snippet_engine
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
								max_indexed_line_length = 1024,
								get_bufnrs = function()
									local bufs = {}
									for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
										if vim.fn.buflisted(bufnr) and vim.fn.getbufvar(bufnr, '&buftype', 'ERROR') ~= 'terminal' then
											local byte_size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
											if byte_size < 1024 * 1024 then
												bufs[bufnr] = true
											end
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
						if snippet_engine == 'ultisnips' then
							vim.fn["UltiSnips#Anon"](args.body)
						else
							require('luasnip').lsp_expand(args.body)
						end
					end,
				},
				confirmation = {
					get_commit_characters = function(commit_characters)
						local filtered_characters = {}
						for _, char in ipairs(commit_characters) do
							if char ~= '(' then
								table.insert(filtered_characters, char)
							end
						end
						return filtered_characters
					end,
				},
				window = {
					completion = {
						--winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
					documentation = {
						max_height = 0,
					}
				},
				mapping = insert_mapping,
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = require("lspkind").cmp_format({
							mode = "symbol_text",
							maxwidth = 50,
							symbol_map = {
								Text = "",
								Method = "",
								Function = "",
								Constructor = "",
								Field = "ﰠ",
								Variable = "",
								Class = "ﴯ",
								Interface = "",
								Module = "",
								Property = "ﰠ",
								Unit = "塞",
								Value = "",
								Enum = "",
								Keyword = "",
								Snippet = "",
								Color = "",
								File = "",
								Reference = "",
								Folder = "",
								EnumMember = "",
								Constant = "",
								Struct = "פּ",
								Event = "",
								Operator = "±",
								TypeParameter = "",
							}
						})(entry, vim_item)
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
				--performance = {
				--	debounce = 300,
				--	throttle = 150
				--},
				sorting = {
					priority_weight = 2,
					comparators = {
						set_priority,
						cmp.config.compare.exact,
						-- cmp.config.compare.scopes,
						cmp.config.compare.score,
						cmp.config.compare.recently_used,
						cmp.config.compare.locality,
						cmp.config.compare.kind,
						-- cmp.config.compare.sort_text,
						cmp.config.compare.order,
						cmp.config.compare.offset,
						cmp.config.compare.length,
					},
				},
			})

			vim.api.nvim_exec_autocmds("FileType", { group = 'lspconfig', modeline = false })
			vim.diagnostic.config({update_in_insert = false })
			--vim.lsp.set_log_level("debug")

			vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
				vim.lsp.diagnostic.on_publish_diagnostics, {
					signs = true,
					underline = false,
					virtual_text = true,
					show_diagnostic_autocmds = {'PostSave'},
					diagnostic_delay = 1000
				}
			)

			if snippet_engine == 'ultisnips' then
				vim.cmd("au! UltiSnips_AutoTrigger")
				vim.cmd("autocmd BufLeave * call UltiSnips#LeavingBuffer()")
			end

			-- complete search
			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' }
				}
			})

			-- complete files and commands
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }
				})
			})

		end,
	},
	--{
	--	"FelikZ/ctrlp-py-matcher",
	--	keys = {
	--		{"<C-p>", "<cmd>CtrlP<CR>", desc="CtrlP"},
	--	},
	--	dependencies = {
	--		'kien/ctrlp.vim',
	--	},
	--	config = function()
	--		--let g:ctrlp_use_caching = 0
	--		vim.g.ctrlp_cache_dir = vim.env.HOME .. '/.cache/ctrlp'
	--		vim.g.ctrlp_follow_symlinks = 1
	--		vim.g.ctrlp_working_path_mode = 'raw'
	--		vim.g.ctrlp_match_func = { match='pymatcher#PyMatch' }
	--		if vim.fn.executable('ag') then
	--			vim.g.ctrlp_user_command = 'ag %s --ignore-case --nogroup --nocolor --hidden --follow -U -p ~/.ignore -l -m 50000 -g ""'
	--		end
	--	end
	--},
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
			vim.g.undotree_RelativeTimestamp = 1
			vim.g.undotree_SetFocusWhenToggle = 1
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		config = function()
			local powerline_darker = require('lualine.themes.powerline')
			powerline_darker.normal.b.bg = '#3a3a3a'
			powerline_darker.normal.c.bg = '#1c1c1c'
			powerline_darker.inactive.c.bg = '#121212'
			require('lualine').setup {
				options = {
					icons_enabled = false,
					theme = powerline_darker,
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
						statusline = 5000,
						tabline = 5000,
						winbar = 5000,
					}
				},
				sections = {
					lualine_a = {'mode',},
					lualine_b = {
						{
							function()
								local starts = vim.fn.line("v")
								local ends = vim.fn.line(".")
								local count = starts <= ends and ends - starts + 1 or starts - ends + 1
								local wc = vim.fn.wordcount()
								return count .. ":" .. wc["visual_chars"]
							end,
							color = { fg = '#eba200', bg = '#875f00', gui='bold' },
							separator = { left = '', right = '' },
							cond = function()
								return vim.fn.mode():find("[Vv]") ~= nil
							end,
						},
						'branch',
						{'diagnostics', colored=true},
					},
					lualine_c = {{'filename', path=1}},
					lualine_x = {
						'encoding',
						'fileformat',
						'filetype'
				},
					lualine_y = {'progress'},
					lualine_z = {
						{
							function()
								local command = 'git --git-dir="$TIMETRACK_GIT_DIR" timetrack -cs'
								local handle = io.popen(command)
								local result = handle:read("*a")
								handle:close()
								return result
							end,
							cond = function(arg)
								return vim.bo.filetype == "toggleterm" and os.getenv('TIMETRACK_GIT_DIR') ~= nil
							end,
						},
						'location'
					},
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
				--tabline = {
				--	lualine_a = {
				--		{
				--			'tabs',
				--			tab_max_length = 40,
				--			mode = 2,
				--			path = 0,
				--		}
				--	},
				--	lualine_b = {},
				--	lualine_c = {},
				--	lualine_x = {},
				--	lualine_y = {},
				--	lualine_z = {},
				--},
				winbar = {},
				inactive_winbar = {},
				extensions = {}
			}

			local function fancyTabLine()
				local s = ''

				local tabcount = vim.fn.tabpagenr('$')

				for i = 1, tabcount do
					-- Define the action for clicking on the tab, which is to switch to the tab
					local tab_click = '%' .. i .. 'T'

					-- Get buffer number
					local bufnr = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]

					-- Write name
					local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')
					if #bufname > 30 then
						bufname = bufname:sub(1, 29) .. '…'
					end
					if bufname == '' then
						bufname = 'Tab ' .. i
					end

					local current_tab_type = 'Normal'
					-- Set highlight
					if i == vim.fn.tabpagenr() then
						-- Selected tab highlight
						s = s .. '%#TabLineSel#'
						current_tab_type = 'Sel'
					else
						-- Unselected tab highlight
						s = s .. '%#TabLine#'
					end

					local next_tab_type = 'Fill'
					if i <= tabcount - 1 then
						next_tab_type = 'Normal'
					end
					if i + 1 == vim.fn.tabpagenr() then
						next_tab_type = 'Sel'
					end

					-- Add tab label and click action
					s = s .. tab_click .. ' ' .. bufname .. ' '

					if i == vim.fn.tabpagenr() then
						s = s .. '%#TabLineSepSel#'
					else
						s = s .. '%#TabLineSep#'
					end
					s = s .. '%#TabLine' .. current_tab_type .. 'To' .. next_tab_type .. '#'

					-- Add tab separator
					if current_tab_type == 'Normal' and next_tab_type == 'Normal' then
						s = s .. ''
					else
						s = s .. ''
					end
				end

				-- Fill to the right
				s = s .. '%#TabLineFill#'

				return s
			end
			_G.FancyTabLine = fancyTabLine
			vim.o.tabline = '%!v:lua.FancyTabLine()'
		end
	},
	{
		'lewis6991/gitsigns.nvim',
		event = 'InsertEnter',
		config = function()
			local gitsigns = require('gitsigns')
			if type(gitsigns) ~= "table" then
				return
			end
			gitsigns.setup {
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
				sign_priority = 0,
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
		filetype = {'javascript', 'typescript'},
		config = function()
			vim.g.javascript_conceal = 1
			vim.g.javascript_conceal_function   = "∫"
			vim.g.javascript_conceal_null       = "Ø"
			vim.g.javascript_conceal_this       = "@"
			vim.g.javascript_conceal_return     = "❰"
			vim.g.javascript_conceal_undefined  = "¿"
			vim.g.javascript_conceal_NaN        = "Ṉ"
			vim.g.javascript_conceal_prototype  = "¶"
			vim.g.javascript_conceal_static     = "•"
			vim.g.javascript_conceal_super      = "Ω"
		end
	},
	{
		'mattn/emmet-vim',
		event = 'InsertEnter',
		filetype = {'html', 'htmldjango'}
	},
	{
		'vim-scripts/po.vim--Jelenak',
		event = 'InsertEnter',
		filetype = {'po'}
	},
	{
		'tikhomirov/vim-glsl',
		event = 'InsertEnter',
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
		cmd = {'Git', 'Gdiffsplit'},
	},
	--{
	--	"roblillack/vim-bufferlist",
	--	keys = {
	--		{"<F3>", "<cmd>call BufferList()<CR>", desc="Buffer list"},
	--	},
	--},
	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
	},
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim'
		},
		cmd = {'Telescope'},
		init = function()
			vim.keymap.set('n', '<leader>fg', "<Cmd>Telescope live_grep<CR>", {})
			vim.keymap.set('n', '<leader>ff', "<Cmd>Telescope find_files<CR>", {})
			vim.keymap.set('n', '<C-j>', "<Cmd>Telescope live_grep<CR>", {})
			vim.keymap.set('n', '<C-p>', function()
				local opts = {
					layout_config = {
						prompt_position = 'bottom',
						bottom_pane = {
							prompt_position = "bottom",
							preview_cutoff = 120,
							preview_width = 0.4,
						},
					},
					--previewer = false,
					prompt_title = false,
					border = false,
				}
				local current_file = vim.fn.expand("%")
				if current_file ~= '' then
					opts.file_ignore_patterns = { current_file }
				end
				opts.follow = true
				local theme = require('telescope.themes').get_ivy(opts);
				require'telescope.builtin'.find_files(theme)
			end, {})
			vim.keymap.set('n', '<F1>', function()
				require'telescope.builtin'.buffers({
					layout_strategy = "vertical",
					layout_config = {
						prompt_position = "top",
						width = 0.7,
						mirror = true
					},
					sort_mru = true,
					show_all_buffers = true,
					file_ignore_patterns = {},
					previewer = false,
				})
			end, {})
		end,
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
					--prompt_prefix = "  ",
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
						n = {
							["q"] = require("telescope.actions").close,
							["<F1>"] = require("telescope.actions").close,
							['<c-d>'] = require('telescope.actions').delete_buffer
						},
						i = {
							["<ESC>"] = require("telescope.actions").close,
							["<F1>"] = require("telescope.actions").close,
							['<c-d>'] = require('telescope.actions').delete_buffer
						},
					},
				},

				extensions_list = {"themes", "terms"},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					}
				},
			})
			require('telescope').load_extension('fzf')
		end
	},
	{
		'akinsho/toggleterm.nvim',
		cmd = {'ToggleTerm', 'TermExec'},
		config = function()
			require("toggleterm").setup({
				direction = 'tab',
				on_create = function(t)
					vim.keymap.set('n', '<C-q>', function() vim.cmd('quit') end, { buffer = t.bufnr })
					vim.keymap.set('n', 'q', function() vim.cmd('quit') end, { buffer = t.bufnr })
				end,
				on_open = function(t)
					vim.cmd('nohlsearch')
					vim.cmd("startinsert!")
				end,
			})
		end
	},
	{
		dir = vim.fn.stdpath("config") .. "/pack/colors/opt/mirec",
	},
	'nvim-lua/plenary.nvim',
	{
		'echasnovski/mini.nvim',
		version = false,
		config = function()
			require('mini.align').setup()
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				init = function()
					-- disable rtp plugin, as we only need its queries for mini.ai
					-- In case other textobject modules are enabled, we will load them
					-- once nvim-treesitter is loaded
					require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
					load_textobjects = true
				end,
			},
		},
		cmd = { "TSUpdateSync" },
		keys = {
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = "x" },
		},
		---@type TSConfig
		opts = {
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
				disable = function(lang, buf)
					local max_filesize = 1024 * 1024 -- 1 MB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
			indent = {
				enable = false
			},
			ensure_installed = {
				"python",
				"javascript",
				"typescript",
				"vue",
				"lua",
				"php",
				"html",
			},
			incremental_selection = {
				enable = false,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		},
		---@param opts TSConfig
		config = function(_, opts)
			if opts == nil then
				return
			end
			if type(opts.ensure_installed) == "table" then
				---@type table<string, boolean>
				local added = {}
				opts.ensure_installed = vim.tbl_filter(function(lang)
					if added[lang] then
						return false
					end
					added[lang] = true
					return true
				end, opts.ensure_installed)
			end
			require("nvim-treesitter.configs").setup(opts)

			if load_textobjects then
				-- PERF: no need to load the plugin, if we only need its queries for mini.ai
				if opts.textobjects then
					for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
						if opts.textobjects[mod] and opts.textobjects[mod].enable then
							local Loader = require("lazy.core.loader")
							Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
							local plugin = require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
							require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
							break
						end
					end
				end
			end
		end,
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require('mason').setup()
		end,
		build = ":MasonUpdate" -- :MasonUpdate updates registry contents
	},
	{
		"norcalli/nvim-colorizer.lua",
		cmd = "ColorizerToggle",
		config = function()
			vim.cmd("set termguicolors")
			require("colorizer").setup()
		end,
	},
	{
		"honza/vim-snippets",
		lazy = true
	},
	{
		"SirVer/ultisnips",
		lazy = snippet_engine ~= 'ultisnips',
		enabled = snippet_engine == 'ultisnips',
		init = function()
			vim.g.UltiSnipsExpandTrigger="<TAB>"
			vim.g.UltiSnipsJumpForwardTrigger="<TAB>"
			vim.g.UltiSnipsJumpBackwardTrigger="<S-TAB>"
			vim.g.UltiSnipsTriggerInVisualMode = 0
			vim.g.UltiSnipsSnippetDirectories = {vim.fn.stdpath("config") .. '/UltiSnips', 'UltiSnips'}
			vim.cmd([[
				function! Ultisnips_get_current_python_class()
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

				function! Ultisnips_get_current_python_method()
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
		end
	},
	{
		'mireq/luasnip-snippets',
		--lazy = snippet_engine == 'ultisnips',
		lazy = true,
		event = 'InsertEnter',
		enabled = snippet_engine ~= 'ultisnips',
		dependencies = {'L3MON4D3/LuaSnip'},
		config = function()
			vim.g.snips_debug = true
			require('luasnip_snippets.common.snip_utils').setup()
		end
	},
	{
		"L3MON4D3/LuaSnip",
		version = "2.*",
		--lazy = snippet_engine == 'ultisnips',
		lazy = true,
		event = 'InsertEnter',
		enabled = snippet_engine ~= 'ultisnips',
		build = "make install_jsregexp",
		dependencies = {
			'nvim-treesitter/nvim-treesitter',
		},
		config = function()
			local ls = require('luasnip')
			ls.setup({
				load_ft_func = require('luasnip_snippets.common.snip_utils').load_ft_func,
				ft_func = require('luasnip_snippets.common.snip_utils').ft_func,
				store_selection_keys = '<c-x>',
				enable_autosnippets = true,
			})
			--vim.keymap.set({"i", "s"}, "<Tab>", function() if ls.expand_or_jumpable() then ls.expand_or_jump() else vim.api.nvim_input('<C-V><Tab>') end end, {silent = true})
			--vim.keymap.set({"i", "s"}, "<S-Tab>", function() ls.jump(-1) end, {silent = true})
			vim.keymap.set({"i"}, "<Tab>", function() if ls.expandable() then ls.expand() else vim.api.nvim_input('<C-V><Tab>') end end, {silent = true})
			vim.keymap.set({"i", "s"}, "<C-K>", function() ls.jump(1) end, {silent = true})
			vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
			vim.api.nvim_set_keymap("i", "<C-u>", "<Plug>luasnip-next-choice", {})
			vim.api.nvim_set_keymap("s", "<C-u>", "<Plug>luasnip-next-choice", {})
			--vim.keymap.set("i", "<C-u>", function() require("luasnip.extras.select_choice")() end, {})
			--vim.keymap.set("s", "<C-u>", function() require("luasnip.extras.select_choice")() end, {})

			--vim.keymap.set({"i", "s"}, "<Tab>", function() ls.jump(1) end, {silent = true})
			--vim.cmd("snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>")
			--require("luasnip.loaders.from_lua").lazy_load({
			--	paths = { "./lua/luasnip_snippets/" }
			--})
		end
	},
	{
		"mireq/large_file",
		config = function()
			require("large_file").setup()
		end
	},
}, {install={colorscheme={"mirec"}}})
