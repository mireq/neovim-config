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


vim.api.nvim_create_user_command('ReloadColorscheme', [[
TSDisable highlight
TSEnable highlight
exec 'lua require("plenary.reload").reload_module("mirec", true)'
colorscheme mirec
]], {})
