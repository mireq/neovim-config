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
	--'gpanders/editorconfig.nvim',
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
				vim.keymap.set('n', 'K', function()
					vim.lsp.buf.hover({
						border = 'single',
					})
				end)
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

				--if client.server_capabilities.inlayHintProvider then
				--	vim.lsp.inlay_hint.enable(true, {bufnr = bufnr})
				--end
			end

			local function get_kind_priority(entry)
				local kind = entry:get_kind()
				local priority = 100
				if kind == types.lsp.CompletionItemKind.Text then
					priority = 0
				end
				if kind == types.lsp.CompletionItemKind.Snippet then
					priority = 50
				end
				if entry:get_completion_item().copilot then
					priority = 101
				end
				return priority
			end

			-- display text completion at end of file
			local function set_priority(entry1, entry2)
				local entry_kind_2 = entry2:get_kind()
				local entry1_priority = get_kind_priority(entry1)
				local entry2_priority = get_kind_priority(entry2)
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
						'.git',
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
							rope = { enabled = true },
						},

					}
				}
			}

			---- https://www.reddit.com/r/neovim/comments/1f9iakw/lspconfig_renamed_tsserver_to_ts_ls_what_to_do_to/
			--local ts_plugin_path = vim.env.HOME .. '/.npm/lib64/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin'
			--local tsdk_path = vim.env.HOME .. '/.npm/lib64/node_modules/typescript/lib'
			--lspconfig.ts_ls.setup {
			--	init_options = {
			--		plugins = {
			--			{
			--				name = '@vue/typescript-plugin',
			--				location = ts_plugin_path,
			--				languages = { 'typescript', 'vue' },
			--			},
			--		},
			--	},
			--	flags = {
			--		debounce_text_changes = 500
			--	},
			--	on_attach = on_attach,
			--	filetypes = { 'typescript', 'typescriptreact', 'vue' },
			--	settings = {
			--		typescript = {
			--			inlayHints = {
			--				includeInlayParameterNameHints = 'none',
			--				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
			--				includeInlayFunctionParameterTypeHints = false,
			--				includeInlayVariableTypeHints = false,
			--				includeInlayVariableTypeHintsWhenTypeMatchesName = false,
			--				includeInlayPropertyDeclarationTypeHints = false,
			--				includeInlayFunctionLikeReturnTypeHints = false,
			--				includeInlayEnumMemberValueHints = false,
			--			}
			--		},
			--		javascript = {
			--			inlayHints = {
			--				includeInlayParameterNameHints = 'none',
			--				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
			--				includeInlayFunctionParameterTypeHints = false,
			--				includeInlayVariableTypeHints = false,
			--				includeInlayVariableTypeHintsWhenTypeMatchesName = false,
			--				includeInlayPropertyDeclarationTypeHints = false,
			--				includeInlayFunctionLikeReturnTypeHints = false,
			--				includeInlayEnumMemberValueHints = false,
			--			}
			--		}
			--	},
			--	--settings = {
			--	--	typescript = {
			--	--		inlayHints = {
			--	--			includeInlayParameterNameHints = 'all',
			--	--			includeInlayParameterNameHintsWhenArgumentMatchesName = false,
			--	--			includeInlayFunctionParameterTypeHints = true,
			--	--			includeInlayVariableTypeHints = true,
			--	--			includeInlayVariableTypeHintsWhenTypeMatchesName = false,
			--	--			includeInlayPropertyDeclarationTypeHints = true,
			--	--			includeInlayFunctionLikeReturnTypeHints = true,
			--	--			includeInlayEnumMemberValueHints = true,
			--	--		}
			--	--	},
			--	--	javascript = {
			--	--		inlayHints = {
			--	--			includeInlayParameterNameHints = 'all',
			--	--			includeInlayParameterNameHintsWhenArgumentMatchesName = false,
			--	--			includeInlayFunctionParameterTypeHints = true,
			--	--			includeInlayVariableTypeHints = true,
			--	--			includeInlayVariableTypeHintsWhenTypeMatchesName = false,
			--	--			includeInlayPropertyDeclarationTypeHints = true,
			--	--			includeInlayFunctionLikeReturnTypeHints = true,
			--	--			includeInlayEnumMemberValueHints = true,
			--	--		}
			--	--	}
			--	--},
			--}

			--lspconfig.volar.setup {
			--	init_options = {
			--		typescript = {
			--			-- replace with your global TypeScript library path
			--			tsdk = tsdk_path
			--		}
			--	},
			--	flags = {
			--		debounce_text_changes = 500
			--	},
			--	on_attach = on_attach,
			--}


			local vue_language_server_path = vim.env.HOME .. '/.npm/lib64/node_modules/@vue/language-server'
			local vue_plugin = {
				name = '@vue/typescript-plugin',
				location = vue_language_server_path,
				languages = { 'vue' },
				configNamespace = 'typescript',
			}
			local vtsls_config = {
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {
								vue_plugin,
							},
						},
						typescript = {
							suggestionActions = {
								enabled = false
							},
							preferences = {
								importModuleSpecifier = "non-relative",
							},
						},
						javascript = {
							suggestionActions = {
								enabled = false
							},
							preferences = {
								importModuleSpecifier = "non-relative",
							},
						},
					},
				},
				filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
			}

			local vue_ls_config = {
				on_init = function(client)
					client.handlers['tsserver/request'] = function(_, result, context)
						local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'vtsls' })
						if #clients == 0 then
							vim.notify('Could not find `vtsls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
							return
						end
						local ts_client = clients[1]

						local param = unpack(result)
						local id, command, payload = unpack(param)
						ts_client:exec_cmd({
							title = 'vue_request_forward', -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
							command = 'typescript.tsserverRequest',
							arguments = {
								command,
								payload,
							},
						}, { bufnr = context.bufnr }, function(_, r)
								local response_data = { { id, r.body } }
								---@diagnostic disable-next-line: param-type-mismatch
								client:notify('tsserver/response', response_data)
							end)
					end
				end,
				on_attach = on_attach,
			}
			-- nvim 0.11 or above
			vim.lsp.config('vtsls', vtsls_config)
			vim.lsp.config('vue_ls', vue_ls_config)
			vim.lsp.enable({'vtsls', 'vue_ls'})

			vim.api.nvim_create_autocmd('LspAttach', {
				group = lsp_group,
				desc = 'Set buffer-local keymaps and options after an LSP client attaches',
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end
					pcall(vim.keymap.del, 'n', 'K', { buffer = bufnr })
					on_attach(client, bufnr)

					if client.server_capabilities.completionProvider then
						vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
						vim.bo[bufnr].formatexpr = 'v:lua.vim.lsp.formatexpr()'
					end
				end,
			})
			local insert_mapping = cmp.mapping.preset.insert({
				['<C-u>'] = cmp.mapping.scroll_docs(-4),
				['<C-d>'] = cmp.mapping.scroll_docs(4),
				['<C-Space>'] = cmp.mapping.complete(),
				['<C-j>'] = cmp.mapping.confirm({ select = true }),
				--['<C-e>'] = cmp.mapping.abort(),
				--['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			})
			insert_mapping['<C-E>'] = nil

			local lspkind_format = require("lspkind").cmp_format({
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
					Copilot = "",
				}
			})

			cmp.setup({
				sources = cmp.config.sources(
					{
						{
							name = 'copilot',
						},
						{
							name = snippet_engine,
						},
						{
							name = 'nvim_lsp',
						},
						{
							name = 'nvim_lsp_signature_help',
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
							},
							group_index = 2
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
				completion = {
					completeopt = 'menu,menuone,noinsert'
				},
				window = {
					completion = {
						winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
						col_offset = -3,
						side_padding = 0,
					},
					documentation = {
						max_height = 0,
						border = 'rounded',
						winhighlight = 'Normal:FloatDoc,FloatBorder:FloatDocBorder,CursorLine:Visual,Search:None'
						--border = { "⎾", "▔", "⏋", "▕", "⏌", "▁", "⎿", "▏" },
					}
				},
				mapping = insert_mapping,
				formatting = {
					--fields = { "kind", "abbr", "menu" },
					fields = { "kind", "abbr" },
					format = function(entry, vim_item)
						-- Hide function arguments in the completion menu
						vim_item.menu = vim_item.menu or ""
						if vim_item.kind == "Function" or vim_item.kind == "Method" or vim_item.kind == "Copilot" then
							vim_item.abbr = vim_item.abbr:gsub('%b()', '')
						end

						--vim_item.abbr = vim_item.word
						local kind = lspkind_format(entry, vim_item)
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
						require("cmp_copilot.comparators").prioritize,
						set_priority,
						cmp.config.compare.exact,
						-- cmp.config.compare.scopes,
						-- cmp.config.compare.score,
						require("cmp_copilot.comparators").score,
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

			--local hl = vim.api.nvim_get_hl_by_name('PmenuSel', true)
			--local cmp_namespace = vim.api.nvim_create_namespace('nvim-comp')
			--vim.api.nvim_set_hl(cmp_namespace, 'CursorLine', {ctermbg=238})
			----vim.api.nvim_set_hl(cmp_namespace, 'CmpItemKindSnippet', {ctermfg=255, ctermbg=23})

			--cmp.event:on("menu_opened", function(window)
			--	vim.api.nvim_win_set_hl_ns(window.window.entries_win.win, cmp_namespace)
			--	--local hl = vim.api.nvim_get_hl_by_name('PmenuSel', true)
			--	--print(vim.inspect(hl))
			--end)


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
				["<c-j>"] = {
					c = cmp.mapping.confirm({ select = false }),
				},
				sources = {
					{ name = 'buffer' }
				}
			})

			-- complete files and commands
			cmp.setup.cmdline(':', {
				--mapping = cmp.mapping.preset.cmdline(),
				mapping = cmp.mapping.preset.cmdline({
					["<c-j>"] = {
						c = cmp.mapping.confirm({ select = false }),
					},
				}),
				sources = cmp.config.sources({
					{
						name = 'path',
						option = {
							trailing_slash = false
						}
					}
				}, {
					{ name = 'cmdline' }
				})
			})

		end,
	},
	--{
	--	dir = vim.fn.stdpath("config") .. "/pack/colors/opt/killor",
	--	ft = 'python'
	--},
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
			powerline_darker.normal.b.bg = '#444444'
			powerline_darker.normal.c.bg = '#262626'
			powerline_darker.inactive.c.bg = '#1c1c1c'
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
						refresh_time = 1000,
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
						{
							'copilot',
							-- Default values
							symbols = {
								status = {
									icons = {
										enabled = "  ",
										sleep = "  ",   -- auto-trigger disabled
										disabled = " ",
										warning = "𥉉 ",
										unknown = " "
									},
									hl = {
										enabled = "#50FA7B",
										sleep = "#AEB7D0",
										disabled = "#6272A4",
										warning = "#FFB86C",
										unknown = "#FF5555"
									}
								},
								spinners = {' '},
								spinner_color = "#6272A4"
							},
							show_colors = false,
							show_loading = true
						},
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

			vim.api.nvim_create_autocmd({'WinEnter', 'BufEnter', 'BufWritePost', 'SessionLoadPost', 'FileChangedShellPost', 'VimResized', 'Filetype', 'CursorMoved', 'CursorMovedI', 'ModeChanged'}, {
				callback = function(e)
					require('lualine').refresh()
				end
			})
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
				signs_staged_enable = true,
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
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map('n', ']c', function()
						if vim.wo.diff then return ']c' end
						vim.schedule(function() gs.next_hunk() end)
						return '<Ignore>'
					end, {expr=true})

					map('n', '[c', function()
						if vim.wo.diff then return '[c' end
						vim.schedule(function() gs.prev_hunk() end)
						return '<Ignore>'
					end, {expr=true})

					-- Actions
					map('n', '<leader>hs', gs.stage_hunk)
					map('n', '<leader>hr', gs.reset_hunk)
					map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
					map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
					map('n', '<leader>hS', gs.stage_buffer)
					map('n', '<leader>hu', gs.undo_stage_hunk)
					map('n', '<leader>hR', gs.reset_buffer)
					map('n', '<leader>hp', gs.preview_hunk)
					map('n', '<leader>hb', function() gs.blame_line{full=true} end)
					map('n', '<leader>tb', gs.toggle_current_line_blame)
					map('n', '<leader>hd', gs.diffthis)
					map('n', '<leader>hD', function() gs.diffthis('~') end)
					map('n', '<leader>td', gs.toggle_deleted)

					-- Text object
					map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
				end
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
		init = function()
			vim.keymap.set('n', 'sg', "<Cmd>tab Git<CR>", {})
			vim.g.fugitive_summary_format = "%<(16,trunc)%an || %s"
		end,
		config = function()
			vim.api.nvim_create_autocmd({"DirChanged"}, {
				callback = function(e)
					if e.match == 'global' then
						vim.call('FugitiveDetect', e.file)
					end
				end
			})
		end
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
		event = 'InsertEnter',
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
			vim.keymap.set('n', '<C-n>', function()
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
					},
					["ui-select"] = {
						require("telescope.themes").get_dropdown {}
					},
				},
			})
			require('telescope').load_extension('fzf')
			require("telescope").load_extension("ui-select")
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
	--'nvim-lua/plenary.nvim',
	--{
	--	'echasnovski/mini.nvim',
	--	version = false,
	--	config = function()
	--		require('mini.align').setup()
	--	end
	--},
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
				use_languagetree = false,
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
				"vimdoc",
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

			--local is_supported = function(ft)
			--	for __, lang in ipairs(opts.ensure_installed) do
			--		if lang == ft then
			--			return true
			--		end
			--	end
			--	return false
			--end

			--opts.highlight.is_supported = is_supported
			--opts.indent.is_supported = is_supported
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
			vim.api.nvim_set_keymap("i", "<C-y>", "<Plug>luasnip-next-choice", {})
			vim.api.nvim_set_keymap("s", "<C-y>", "<Plug>luasnip-next-choice", {})
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
	--{
	--	"folke/which-key.nvim",
	--	event = "VeryLazy",
	--	init = function()
	--		vim.o.timeout = true
	--		vim.o.timeoutlen = 300
	--	end,
	--	opts = {
	--		-- your configuration comes here
	--		-- or leave it empty to use the default settings
	--		-- refer to the configuration section below
	--	}
	--},
	'ii14/neorepl.nvim',
	{
		"zbirenbaum/copilot.lua",
		enabled = enable_ai,
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				panel = {
					enabled = false,
					auto_refresh = true,
				},
				suggestion = {
					enabled = false,
					-- use the built-in keymapping for "accept" (<M-l>)
					auto_trigger = true,
					accept = false, -- disable built-in keymapping
				},
				filetypes = {
					python = true,
					php = true,
					po = true,
					html = true,
					javascript = true,
					htmldjango = true,
					gitcommit = true,
					scss = true,
					vue = true,
					typescript = true,
					markdown = true,
					["*"] = false,
				},
			})

			-- hide copilot suggestions when cmp menu is open
			-- to prevent odd behavior/garbled up suggestions
			local cmp_status_ok, cmp = pcall(require, "cmp")
			if cmp_status_ok then
				cmp.event:on("menu_opened", function()
					vim.b.copilot_suggestion_hidden = true
				end)

				cmp.event:on("menu_closed", function()
					vim.b.copilot_suggestion_hidden = false
				end)
			end
		end,
	},
	{
		"JosefLitos/cmp-copilot",
		event = "InsertEnter",
		opts = {},
		dependencies = "copilot.lua"
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		cmd = {'CopilotChat', 'CopilotChatClose', 'CopilotChatCommit', 'CopilotChatCommitStaged', 'CopilotChatDebugInfo', 'CopilotChatDocs', 'CopilotChatExplain', 'CopilotChatFix', 'CopilotChatFixDiagnostic', 'CopilotChatLoad', 'CopilotChatOpen', 'CopilotChatOptimize', 'CopilotChatReset', 'CopilotChatReview', 'CopilotChatSave', 'CopilotChatTests'},
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		opts = {
			debug = false,
			window = {
				layout = 'horizontal',
				relative = 'editor',
			},
		},
	},
	{ 'AndreM222/copilot-lualine' },
	--{ 'nathanaelkane/vim-indent-guides' },
	{ 'junegunn/gv.vim' },
	{
		'niuiic/quickfix.nvim',
		dependencies = {
			'niuiic/core.nvim'
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"gentoo/gentoo-syntax",
	},
	{
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},

--  {{
--    'tadaa/vimade',
--    -- default opts (you can partially set these or configure them however you like)
--    opts = {
--      -- Recipe can be any of 'default', 'minimalist', 'duo', and 'ripple'
--      -- Set animate = true to enable animations on any recipe.
--      -- See the docs for other config options.
--      recipe = {'default', {animate=false}},
--      ncmode = 'windows', -- use 'windows' to fade inactive windows
--      fadelevel = 0.7, -- any value between 0 and 1. 0 is hidden and 1 is opaque.
--      tint = {
--        -- bg = {rgb={0,0,0}, intensity=0.3}, -- adds 30% black to background
--        -- fg = {rgb={0,0,255}, intensity=0.3}, -- adds 30% blue to foreground
--        -- fg = {rgb={120,120,120}, intensity=1}, -- all text will be gray
--        -- sp = {rgb={255,0,0}, intensity=0.5}, -- adds 50% red to special characters
--        -- you can also use functions for tint or any value part in the tint object
--        -- to create window-specific configurations
--        -- see the `Tinting` section of the README for more details.
--      },
--
--      -- Changes the real or theoretical background color. basebg can be used to give
--      -- transparent terminals accurating dimming.  See the 'Preparing a transparent terminal'
--      -- section in the README.md for more info.
--      -- basebg = [23,23,23],
--      basebg = '',
--
--      -- prevent a window or buffer from being styled. You 
--      blocklist = {
--        default = {
--          buf_opts = { buftype = {'prompt', 'terminal'} },
--          win_config = { relative = true },
--          -- buf_name = {'name1','name2', name3'},
--          -- buf_vars = { variable = {'match1', 'match2'} },
--          -- win_opts = { option = {'match1', 'match2' } },
--          -- win_vars = { variable = {'match1', 'match2'} },
--        },
--        -- any_rule_name1 = {
--        --   buf_opts = {}
--        -- },
--        -- only_behind_float_windows = {
--        --   buf_opts = function(win, current)
--        --     if (win.win_config.relative == '')
--        --       and (current and current.win_config.relative ~= '') then
--        --         return false
--        --     end
--        --     return true
--        --   end
--        -- },
--      },
--      -- Link connects windows so that they style or unstyle together.
--      -- Properties are matched against the active window. Same format as blocklist above
--      link = {},
--      groupdiff = true, -- links diffs so that they style together
--      groupscrollbind = false, -- link scrollbound windows so that they style together.
--
--      -- enable to bind to FocusGained and FocusLost events. This allows fading inactive
--      -- tmux panes.
--      enablefocusfading = false,
--
--      -- when nohlcheck is disabled the highlight tree will always be recomputed. You may
--      -- want to disable this if you have a plugin that creates dynamic highlights in
--      -- inactive windows. 99% of the time you shouldn't need to change this value.
--      nohlcheck = true,
--    }
--  }}

}, {install={colorscheme={"mirec"}}})
