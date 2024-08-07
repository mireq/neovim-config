local M = {}

local color_utils = require("mirec_color_utils")


local colorscheme = {
	{"Boolean", {ctermfg=192, cterm={bold=true}}},
	{"Character", {ctermfg=181, cterm={bold=true}}},
	{"ColorColumn", {ctermbg=233}},
	{"Comment", {ctermfg=243}},
	{"Conditional", {ctermfg=229, cterm={bold=true}}},
	{"Conceal", {ctermfg=120}},
	{"Constant", {ctermfg=181, cterm={bold=true}}},
	--{"Cursor", {ctermfg=16, ctermbg=145}},
	{"Cursor", {ctermfg=9, ctermbg=192, cterm={bold=true, nocombine=true}}},
	{"CursorColumn", {ctermbg=232}},
	{"CursorLine", {ctermbg=233}},
	{"CursorLineNr", {ctermfg=255, ctermbg=125, cterm={bold=true, nocombine=true}}},
	{"CursorLineSign", {ctermfg=255, ctermbg=125, cterm={bold=true, nocombine=true}}},
	{"Debug", {ctermfg=181, cterm={bold=true}}},
	{"Define", {ctermfg=157, cterm={bold=true}}},
	{"Delimiter", {ctermfg=193}},
	{"DiffAdd", {ctermbg=22}},
	{"DiffChange", {ctermbg=24}},
	{"DiffDelete", {ctermfg=234, ctermbg=88}},
	{"DiffText", {ctermfg=231, ctermbg=31, cterm={bold=true}}},
	{"Directory", {ctermfg=231, cterm={bold=true}}},
	{"Error", {ctermfg=231, ctermbg=9}},
	{"ErrorMsg", {ctermfg=16, ctermbg=6}},
	{"Exception", {ctermfg=123, cterm={underline=true}}},
	{"Float", {ctermfg=219}},
	{"FoldColumn", {ctermfg=181, ctermbg=235}},
	{"Folded", {ctermfg=181, ctermbg=16}},
	{"Function", {ctermfg=228}},
	{"Identifier", {ctermfg=153, cterm={bold=true}}},
	{"phpMethodsVar", {ctermfg=151}},
	{"Include", {ctermfg=156, cterm={bold=true}}},
	{"IncSearch", {ctermfg=231, ctermbg=163, cterm={bold=true}}},
	{"Keyword", {ctermfg=227, cterm={bold=true}}},
	{"Label", {ctermfg=229, cterm={bold=true, underline=true}}},
	{"LineNr", {ctermfg=244, ctermbg=234}},
	{"Macro", {ctermfg=157, cterm={bold=true}}},
	{"MatchParen", {ctermfg=255, ctermbg=125, cterm={bold=true, nocombine=true}}},
	{"ModeMsg", {ctermfg=181, cterm={bold=true}}},
	{"MoreMsg", {ctermfg=231, cterm={bold=true}}},
	{"NonText", {ctermfg=104}},
	{"Normal", {ctermfg=252, ctermbg=16}},
	{"Number", {ctermfg=111}},
	{"Operator", {ctermfg=153, cterm={bold=true}}},
	{"Pmenu", {ctermfg=252, ctermbg=235}},
	{"PmenuSel", {ctermbg=238}},
	--{"PmenuSel", {ctermfg=16, ctermbg=156}},
	{"PmenuSbar", {ctermfg=248, ctermbg=237}},
	{"PmenuThumb", {ctermfg=244, ctermbg=244}},
	{"PreCondit", {ctermfg=157, cterm={bold=true}}},
	{"PreProc", {ctermfg=156}},
	{"Question", {ctermfg=231, cterm={bold=true}}},
	{"Repeat", {ctermfg=222, cterm={bold=true}}},
	{"Search", {ctermfg=227, ctermbg=16, cterm={bold=true, reverse=true}}},
	{"CurSearch", {link="Search"}},
	{"SignColumn", {ctermfg=244, ctermbg=233}},
	{"SpecialChar", {ctermfg=181, cterm={bold=true}}},
	{"SpecialComment", {ctermfg=181, cterm={bold=true}}},
	{"Special", {ctermfg=192}},
	{"SpecialKey", {ctermfg=8}},
	{"SpellBad", {ctermfg=174, ctermbg=233, undercurl=true, cterm={underline=true}}},
	{"Statement", {ctermfg=229, cterm={bold=true}}},
	{"doxygenBrief", {ctermfg=249, cterm={bold=true}}},
	{"doxygenSpecialOnelineDesc", {ctermfg=123}},
	{"StatusLine", {ctermbg=16, ctermfg=28, cterm={bold=true}}},
	{"StatusLineNC", {ctermfg=234, ctermbg=252}},
	{"StorageClass", {ctermfg=87, cterm={bold=true}}},
	{"String", {ctermfg=174}},
	{"Structure", {ctermfg=192, cterm={bold=true}}},
	{"Tag", {ctermfg=153, cterm={bold=true}}},
	{"Title", {ctermfg=231, cterm={bold=true}}},
	{"Todo", {ctermfg=231, ctermbg=16, cterm={bold=true}}},
	{"Typedef", {ctermfg=206, cterm={bold=true, underline=true}}},
	{"Type", {ctermfg=153}},
	{"Underlined", {ctermfg=81, cterm={underline=true}}},
	{"VertSplit", {ctermfg=236, ctermbg=16}},
	{"Visual", {ctermfg=210, ctermbg=236}},
	{"VisualNOS", {ctermfg=234, ctermbg=210, cterm={bold=true, underline=true}}},
	{"WarningMsg", {ctermfg=231, ctermbg=234, cterm={bold=true}}},
	{"WildMenu", {ctermfg=16, ctermbg=181}},
	{"Whitespace", {ctermfg=240}},
	{"WinSeparator", {ctermfg=236}},

	{"OverLength", {ctermbg=237}},
	{"WarnLength", {ctermbg=235}},

	{"BufferSelected", {ctermfg=227, ctermbg=16, cterm={bold=true, reverse=true}}},
	{"BufferNormal", {ctermfg=252, ctermbg=16}},

	{"TabLineFill", {ctermfg=246, ctermbg=234}},
	{"TabLineSel", {ctermfg=22, ctermbg=148}},
	{"TabLine", {ctermfg=246, ctermbg=236}},

	{"TabLineSelToFill", {ctermfg=148, ctermbg=234}},
	{"TabLineSelToNormal", {ctermfg=148, ctermbg=236}},
	{"TabLineNormalToFill", {ctermfg=236, ctermbg=234}},
	{"TabLineNormalToNormal", {ctermfg=246, ctermbg=236}},
	{"TabLineNormalToSel", {ctermfg=236, ctermbg=148}},

	{"TabLineSep", {ctermfg=236, ctermbg=234}},
	{"TabLineSepSel", {ctermfg=148, ctermbg=236}},

	{"QtObject", {ctermfg=120}},

	{"NormalFloat", {link="Pmenu"}},
	{"FloatBorder", {link="WinSeparator"}},
	{"FloatTitle", {link="Title"}},
	{"FloatFooter", {link="Title"}},

	{"FloatDoc", {ctermbg=232}},
	{"FloatDocBorder", {ctermbg=232, ctermfg=240}},

	{"GitSignsAdd", {link="DiffAdd"}},
	{"GitSignsChange", {link="DiffChange"}},
	{"GitSignsDelete", {link="DiffDelete"}},

	{"GitSignsStagedAddNr", {ctermbg=34, ctermfg=16}},
	{"GitSignsStagedChangeNr", {ctermbg=45, ctermfg=16}},
	{"GitSignsStagedDeleteNr", {ctermbg=196, ctermfg=16}},

	{"outlTags", {ctermfg=51}},
	{"OL1", {ctermfg=231, ctermbg=232, cterm={bold=true, underline=true}}},
	{"OL2", {ctermfg=231, cterm={bold=true}}},
	{"OL3", {ctermfg=228, cterm={bold=true}}},
	{"OL4", {ctermfg=254}},
	{"OL5", {ctermfg=189}},
	{"OL6", {ctermfg=187}},
	{"OL7", {ctermfg=146}},
	{"OL8", {ctermfg=144}},
	{"OL9", {ctermfg=103}},

	{"BT1", {ctermfg=230}},
	{"BT2", {ctermfg=230}},
	{"BT3", {ctermfg=230}},
	{"PT1", {ctermfg=196}},
	{"PT2", {ctermfg=196}},
	{"PT3", {ctermfg=196}},
	{"TA1", {ctermfg=230}},
	{"TA2", {ctermfg=230}},
	{"TA3", {ctermfg=230}},
	{"UT1", {ctermfg=196}},
	{"UT2", {ctermfg=196}},
	{"UT3", {ctermfg=196}},
	{"UB1", {ctermfg=196}},
	{"UB2", {ctermfg=196}},
	{"UB3", {ctermfg=196}},

	{"RegionMaker", {ctermfg=235, ctermbg=253}},
	{"cCustomFunc", {ctermfg=158}},
	{"cCustomClass", {ctermfg=159}},

	{"cppFuncDef", {link="Special"}},
	{"diffFile", {link="Conceal"}},


	{"Attribute", {ctermfg=158}},
	{"CallClass", {ctermfg=120, cterm={nocombine=true, bold=false}}},
	{"DefineClass", {ctermfg=228}},
	{"CallStaticClass", {ctermfg=231, cterm={bold=true}}},
	{"CallFunction", {ctermfg=153}},
	{"CallPrivateFunction", {ctermfg=204}},
	{"Self", {ctermfg=144, cterm={bold=true}}},


	{"todoOkSymbol", {ctermfg=34}},
	{"todoBadSymbol", {ctermfg=196}},
	{"todoPartSymbol", {ctermfg=191}},
	{"todoOk", {ctermfg=241}},
	{"todoBad", {ctermfg=227}},
	{"todoPart", {ctermfg=136}},

	{"mailQuoted1", {ctermfg=191}},
	{"mailQuoted2", {ctermfg=94}},
	{"mailQuoted3", {ctermfg=24}},
	{"mailQuoted4", {ctermfg=88}},

	{"IndentGuidesOdd", {ctermbg=16, ctermfg=244}},
	{"IndentGuidesEven", {ctermbg=233, ctermfg=244}},

	{"IndentBlanklineSpaceIndent1", {ctermfg=242, ctermbg=16}},
	{"IndentBlanklineSpaceIndent2", {ctermfg=242, ctermbg=232}},
	{"IndentBlanklineIndent1", {ctermfg=242, ctermbg=16}},
	{"IndentBlanklineIndent2", {ctermfg=242, ctermbg=232}},

	{"CmpItemAbbrMatch", {cterm={bold=true}, ctermfg=231}},
	{"CmpItemAbbrMatchFuzzy", {cterm={bold=true}, ctermfg=231}},
	{"CmpItemMenu", {cterm={italic=true}}},
	{"CmpItemAbbrDeprecated", {ctermfg=244}},

	{"CmpItemKindField", {ctermfg=131, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindProperty", {ctermfg=131, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindEvent", {ctermfg=131, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindEnum", {ctermfg=28, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindKeyword", {ctermfg=28, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindConstant", {ctermfg=23, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindConstructor", {ctermfg=23, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindReference", {ctermfg=23, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindFunction", {ctermfg=90, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindStruct", {ctermfg=124, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindClass", {ctermfg=125, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindModule", {ctermfg=126, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindOperator", {ctermfg=127, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindVariable", {ctermfg=55, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindSnippet", {ctermfg=23, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindFile", {ctermfg=28, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindFolder", {ctermfg=28, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindUnit", {ctermfg=58, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindText", {ctermfg=58, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindMethod", {ctermfg=61, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindValue", {ctermfg=61, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindEnumMember", {ctermfg=61, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindInterface", {ctermfg=66, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindColor", {ctermfg=66, ctermbg=255, cterm={reverse=true}}},
	{"CmpItemKindTypeParameter", {ctermfg=66, ctermbg=255, cterm={reverse=true}}},

	{"CmpItemKindCopilot", {ctermfg=26, ctermbg=255, cterm={reverse=true}}},

	{"TelescopeInvisible", {ctermfg=233, ctermbg=233}},
	{"TelescopeInvisible2", {ctermfg=235, ctermbg=235}},
	{"TelescopeNormal", {ctermfg=252, ctermbg=233}},
	{"TelescopePromptBorder", {ctermfg=31, ctermbg=31}},
	{"TelescopePromptTitle", {ctermfg=255, ctermbg=31}},
	{"TelescopePromptNormal", {ctermfg=255, ctermbg=31, cterm={bold=true}}},
	{"TelescopePromptCounter", {ctermfg=255, ctermbg=31}},
	{"TelescopePreviewTitle", {ctermfg=255, ctermbg=233}},
	{"TelescopeResultsNormal", {ctermbg=235}},
	{"TelescopePreviewNormal", {ctermbg=233}},
	{"TelescopeResultsTitle", {ctermfg=255, ctermbg=235}},

	{"TelescopeResultsBorder", {link="TelescopeInvisible2"}},
	{"TelescopePreviewBorder", {link="TelescopeInvisible"}},

	{"@variable", {}},
	{"@attribute", {link="Attribute"}},
	{"@property", {link="Attribute"}},
	{"@field", {link="Attribute"}},
	{"@variable.python", {}},
	{"@variable.builtin.python", {link="Self"}},
	{"@variable.class.python", {link="Title"}},
	{"@constant.builtin.python", {link="Boolean"}},
	{"@constant.python", {link="Title"}},
	{"@exception.builtin.python", {link="Structure"}},
	{"@function.builtin.python", {link="Function"}},
	{"@function.call.python", {}},
	{"@function.class_construct.python", {link="CallClass"}},
	{"@function.call_private.python", {link="CallPrivateFunction"}},
	{"@definition.import.python", {}},
	{"@definition.superclasses.python", {link="Title"}},
	{"@definition.decorator.python", {link="Function"}},
	{"@definition.classname.python", {link="DefineClass"}},
	{"@attribute.python", {}},
	{"@field.python", {link="Attribute"}},
	{"@property.python", {}},
	{"@parameter.python", {}},
	{"@tag.vue", {link="Statement"}},
	{"@tag.attribute.vue", {link="Type"}},
	{"@method.vue", {link="Type"}},
	{"@variable.vue", {link="Title"}},
	{"@variable.member.vue", {link="CallClass"}},
	{"@function.method.vue", {link="Define"}},
	{"@punction.special.vue", {link="Type"}},
	{"@keyword.import", {link="PreProc"}},
	{"@type.builtin.python", {link="Type"}},
};

M.setup = function(config)
	color_utils.setup_colorscheme(colorscheme, 'mirec', 'dark')
end

return M
