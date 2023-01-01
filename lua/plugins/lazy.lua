require("lazy").setup({
	"gpanders/editorconfig.nvim",
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			'hrsh7th/cmp-nvim-lsp-signature-help',
			"neovim/nvim-lspconfig",
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
			lspconfig['pylsp'].setup {
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
			lspconfig['pylsp'].manager.try_add()

			--cmp.register_source('buffer', require('cmp_buffer'))
			--cmp.register_source('path', require('cmp_path').new())
			--cmp.register_source('nvim_lsp_signature_help', require('cmp_nvim_lsp_signature_help').new())

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
		end,
	},
})
