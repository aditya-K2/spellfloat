fun! Spellfloat()
	lua require("spellfloat").openWindow()
endfun

fun! GetSuggestion()
	lua require("spellfloat").getSuggestion()
endfun

fun! OPEN()
	lua print(vim.api.nvim_get_current_win())
endfun
