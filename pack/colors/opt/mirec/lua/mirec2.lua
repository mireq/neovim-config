
local M = {}

local color_utils = require("mirec_color_utils")

local colorscheme = {
	{"Boolean", {ctermfg=7, cterm={bold=true}}},
	{"Character", {ctermfg=217, cterm={bold=true}}},
	{"ColorColumn", {ctermbg=234}},
	{"Comment", {ctermfg=8}},
	{"Conditional", {ctermfg=228, cterm={bold=true}}},
	{"Cursor", {ctermfg=0, ctermbg=145}},
	{"CursorColumn", {ctermbg=232}},
	{"CursorLine", {ctermbg=232, cterm={underline=true}}},
	{"Delimiter", {ctermfg=158}},
	{"Directory", {ctermfg=147}},
	{"FoldColumn", {ctermfg=192, ctermbg=235}},
	{"Folded", {ctermfg=192, ctermbg=233}},
	{"Exception", {ctermfg=228, cterm={bold=true}}},
	{"PreProc", {ctermfg=156}},
	{"Identifier", {ctermfg=111}},
	{"IncSearch", {ctermfg=231, ctermbg=18, cterm={bold=true}}},
	{"Label", {ctermfg=228}},
	{"LineNr", {ctermfg=243, ctermbg=235}},
	{"MatchParen", {ctermfg=192, ctermbg=233, cterm={bold=true, reverse=true}}},
	{"ModeMsg", {ctermfg=181, cterm={bold=true}}},
	{"MoreMsg", {ctermfg=231, cterm={bold=true}}},
	{"NonText", {ctermfg=104}},
	{"Normal", {ctermfg=252, ctermbg=233}},
	{"Operator", {ctermfg=158}},
	{"Pmenu", {ctermfg=231, ctermbg=240}},
	{"PmenuSel", {ctermfg=0, ctermbg=156}},
	{"Question", {ctermfg=231, cterm={bold=true}}},
	{"Repeat", {ctermfg=228, cterm={bold=true}}},
	{"Search", {ctermfg=227, ctermbg=233, cterm={bold=true, reverse=true}}},
	{"Special", {ctermfg=217, cterm={bold=true}}},
	{"SpecialKey", {ctermfg=243}},
	{"Statement", {ctermfg=228}},
	{"StatusLine", {cterm={bold=true}, ctermbg=0, ctermfg=2}},
	{"StatusLineNC", {ctermfg=234, ctermbg=252}},
	{"String", {ctermfg=204}},
	{"Title", {ctermfg=231, cterm={bold=true}}},
	{"Type", {ctermfg=121}},
	{"VertSplit", {ctermfg=234, ctermbg=252}},
	{"Visual", {ctermfg=236, ctermbg=210, cterm={reverse=true}}},
	{"VisualNOS", {ctermfg=234, ctermbg=210, cterm={bold=true, underline=true}}},
	{"WarningMsg", {ctermfg=224, ctermbg=234, cterm={bold=true}}},
	{"WildMenu", {ctermfg=0, ctermbg=181}},

	{"CallClass", {ctermfg=122}},
	{"CallStaticClass", {ctermfg=231, cterm={bold=true}}},
	{"CallFunction", {ctermfg=129}},
	{"CallPrivateFunction", {ctermfg=130}},

	{"CallFunction", {ctermfg=111}},

	{"doxygenBrief", {ctermfg=249, cterm={bold=true}}},
	{"doxygenSpecialOnelineDesc", {ctermfg=123}},
}


M.setup = function(config)
	color_utils.setup_colorscheme(colorscheme, 'mirec2', 'dark')
end

return M
