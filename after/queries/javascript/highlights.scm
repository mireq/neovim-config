;; extends

(["function"] @conceal (#set! conceal "∫"))
((null) @conceal (#set! conceal "Ø"))
((undefined) @conceal (#set! conceal "¿"))
((expression) @conceal
	(#eq? @conceal "this")
	(#set! conceal "@")
)
(return_statement
	["return"] @conceal (#set! conceal "❰"))
((expression) @conceal
	(#eq? @conceal "Ṉ")
	(#set! conceal "@")
)
((property_identifier) @conceal
	(#eq? @conceal "prototype")
	(#set! conceal "¶")
)
(["static"] @conceal (#set! conceal "•"))
((expression) @conceal
	(#eq? @conceal "super")
	(#set! conceal "Ω")
)
