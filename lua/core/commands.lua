vim.api.nvim_create_user_command('Reload', '%d|r|1d', {})

vim.api.nvim_create_user_command('ReformatXML', '%!xmllint --format --recover --encode utf-8 - 2>/dev/null', {})
vim.api.nvim_create_user_command('ReplaceDiacritic', [[
execute "silent! '<,'>s/Ľ/\\&#317;/g"
execute "silent! '<,'>s/Š/\\&#352;/g"
execute "silent! '<,'>s/Ť/\\&#356;/g"
execute "silent! '<,'>s/Ž/\\&#381;/g"
execute "silent! '<,'>s/ľ/\\&#318;/g"
execute "silent! '<,'>s/š/\\&#353;/g"
execute "silent! '<,'>s/ť/\\&#357;/g"
execute "silent! '<,'>s/ž/\\&#382;/g"
execute "silent! '<,'>s/Ŕ/\\&#340;/g"
execute "silent! '<,'>s/Ĺ/\\&#313;/g"
execute "silent! '<,'>s/Č/\\&#268;/g"
execute "silent! '<,'>s/Ě/\\&#282;/g"
execute "silent! '<,'>s/Ď/\\&#270;/g"
execute "silent! '<,'>s/Ň/\\&#327;/g"
execute "silent! '<,'>s/Ř/\\&#344;/g"
execute "silent! '<,'>s/Ů/\\&#366;/g"
execute "silent! '<,'>s/ŕ/\\&#341;/g"
execute "silent! '<,'>s/ľ/\\&#314;/g"
execute "silent! '<,'>s/č/\\&#269;/g"
execute "silent! '<,'>s/ě/\\&#283;/g"
execute "silent! '<,'>s/ď/\\&#271;/g"
execute "silent! '<,'>s/ň/\\&#328;/g"
execute "silent! '<,'>s/ř/\\&#345;/g"
execute "silent! '<,'>s/ô/\\&#244;/g"
execute "silent! '<,'>s/Ô/\\&#212;/g"
execute "silent! '<,'>s/Ý/\\&#221;/g"
execute "silent! '<,'>s/ý/\\&#253;/g"
execute "silent! '<,'>s/Á/\\&Aacute;/g"
execute "silent! '<,'>s/á/\\&aacute;/g"
execute "silent! '<,'>s/É/\\&Eacute;/g"
execute "silent! '<,'>s/é/\\&eacute;/g"
execute "silent! '<,'>s/Í/\\&Iacute;/g"
execute "silent! '<,'>s/í/\\&iacute;/g"
execute "silent! '<,'>s/Ó/\\&Oacute;/g"
execute "silent! '<,'>s/ó/\\&oacute;/g"
execute "silent! '<,'>s/Ú/\\&Uacute;/g"
execute "silent! '<,'>s/ú/\\&uacute;/g"
]], {range=true})

vim.api.nvim_create_user_command('HTMLTextHighlight', [[
syntax off
syntax region comment start=/</ end=/>/
syntax region comment start=/</ end=/>/
syntax region comment start=/{%/ end=/%}/
syntax region comment start=/{{/ end=/}}/
syntax region comment start=/{#/ end=/#}/
syntax match Title /{%\s*\(end\)\?trans[^%]*%}/
]], {})


vim.api.nvim_create_user_command('ReloadColorscheme', function()
	vim.cmd.TSDisable('highlight')
	vim.cmd.TSEnable('highlight')
	local current_colorscheme = vim.g.colors_name
	require("plenary.reload").reload_module(current_colorscheme, true)
	vim.cmd('colorscheme ' .. current_colorscheme)
end, {})

vim.api.nvim_create_user_command('HighlightColorscheme', [[
TSDisable highlight
TSEnable highlight
exec 'lua require("plenary.reload").reload_module("mirec_color_utils", true)'
lua require("mirec_color_utils").highlight_colorscheme()
]], {})


vim.api.nvim_create_user_command('Tel', function(opts)
	require("telescope.command").load_command(unpack(opts.fargs))
end, {
	nargs = "*",
	complete = function(_, line)
		local builtin_list = vim.tbl_keys(require "telescope.builtin")
		local extensions_list = vim.tbl_keys(require("telescope._extensions").manager)

		local l = vim.split(line, "%s+")
		local n = #l - 2
		local cmd = l[2]

		if n == 0 then
			local commands = vim.tbl_flatten { builtin_list, extensions_list }
			table.sort(commands)

			return vim.tbl_filter(function(val)
				return vim.startswith(val, l[2])
			end, commands)
		end

		if n == 1 then
			local is_extension = vim.tbl_filter(function(val)
				return val == l[2]
			end, extensions_list)

			if #is_extension > 0 then
				local extensions_subcommand_dict = require("telescope.command").get_extensions_subcommand()
				local commands = extensions_subcommand_dict[l[2]]
				table.sort(commands)

				return vim.tbl_filter(function(val)
					return vim.startswith(val, l[3])
				end, commands)
			end
		end

		local options_list = vim.tbl_keys(require("telescope.config").values)

		if cmd == 'live_grep' then
			table.insert(options_list, 'search_dirs=')
		end

		local last = l[#l]

		if vim.startswith(last, 'search_dirs=') then
			local file_completions = vim.fn.getcompletion(last:sub(13), 'file')
			local completions = {}
			for __, path in ipairs(file_completions) do
				table.insert(completions, 'search_dirs=' .. path)
			end
			return completions
		end

		return vim.tbl_filter(function(val)
			return vim.startswith(val, last)
		end, options_list)
	end,
})
