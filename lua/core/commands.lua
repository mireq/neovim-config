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



local function update_env_vars_from_terminal()
	-- Path to the temporary file
	local tmp_file = os.tmpname()

	-- Function to read the temporary file and update environment variables
	local function set_env_vars()
		local file = io.open(tmp_file, "r")
		if file then
			for line in file:lines() do
				local key, value = line:match("([^=]+)=(.*)")
				if key and value then
					vim.fn.setenv(key, value)
				end
			end
			file:close()
			-- Remove the temporary file after reading
			os.remove(tmp_file)
		end
	end

  -- Get the current buffer number, assuming it's a terminal
  local bufnr = vim.api.nvim_get_current_buf()
  
	-- Obtain the terminal's job ID
	local channel_id = vim.b[bufnr].terminal_job_id

	if channel_id then
		-- Send the 'env' command to the terminal and redirect output to the temporary file
		vim.fn.chansend(channel_id, "\nenv > " .. tmp_file .. "\n")
	end

	-- Give some time for the command to execute and the file to be populated
	vim.defer_fn(function()
		set_env_vars()
	end, 100)
end


vim.api.nvim_create_user_command('TermUpdateEnv', update_env_vars_from_terminal, {})


vim.api.nvim_create_user_command(
	'TermFloatExec',
	function(opts)
		local term_exec_cmd = string.format(':9TermExec direction=float go_back=0 cmd="%s"', opts.args)
		require "toggleterm"
		vim.cmd(term_exec_cmd)
	end,
	{ nargs=1 }
)


vim.api.nvim_create_user_command('CopyFilenameToClipboard', function()
	vim.fn.setreg('+', vim.fn.expand('%:p'))
end, {})
