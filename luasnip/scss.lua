local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("rc", { t("rem_calc("), i(1), t(")") }),
}
