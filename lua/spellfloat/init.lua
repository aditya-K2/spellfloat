SelectedWordSuggestion = ""
local hlCursorLine = vim.api.nvim_create_namespace("CursorLine")
local currentPosition = 0
local suggestions


local getMisspelledWords = function(inputTable)

	local t = {}
	for i = 1, #inputTable do
		local word = (vim.fn.spellbadword(inputTable[i]))[1]
		if( word ~= "") then
			table.insert(t, word)
		end
	end
	return t

end

local function getSuggestion(useInSub)

	if useInSub then
		SubWord = vim.api.nvim_get_current_line()
		vim.cmd("q!")
	else
		SelectedWordSuggestion = vim.api.nvim_get_current_line()
		vim.cmd("q!")
		vim.cmd("normal! ciw" .. SelectedWordSuggestion)
	end

end

local function setKeymaps(buffer, arg)

	vim.api.nvim_buf_set_keymap(buffer, 'n', "<CR>", ":<cmd> lua require('spellfloat').getSuggestion(" .. arg .. ")<CR><CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buffer, 'n', "<Space>", ":<cmd> lua require('spellfloat').getSuggestion(" .. arg .. ")<CR><CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buffer, 'n', "<Tab>", ":<cmd> lua require('spellfloat').incrementHighlight()<CR><CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buffer, 'n', "<S-Tab>", ":<cmd> lua require('spellfloat').decrementHighlight()<CR><CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buffer, 'n', "j", ":<cmd> lua require('spellfloat').incrementHighlight()<CR><CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buffer, 'n', "k", ":<cmd> lua require('spellfloat').decrementHighlight()<CR><CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buffer, 'n', "<Esc>", ":q!<CR>", { noremap = true, silent = true })

end

local function incrementHighlight(buffer)

	if currentPosition < #suggestions then
		currentPosition = currentPosition + 1
		vim.api.nvim_buf_clear_namespace(buffer, hlCursorLine,0, -1)
		vim.api.nvim_buf_add_highlight(buffer, hlCursorLine, "PmenuSel", currentPosition , 0, -1)
		vim.cmd("normal! j0<CR>")
	elseif currentPosition > #suggestions - 1 then
		currentPosition = #suggestions - 1
		vim.api.nvim_buf_clear_namespace(buffer, hlCursorLine,0, -1)
		vim.api.nvim_buf_add_highlight(buffer, hlCursorLine, "PmenuSel", currentPosition , 0, -1)
	end

end

local function decrementHighlight(buffer)

	if currentPosition > 0 then
		currentPosition = currentPosition - 1
		vim.api.nvim_buf_clear_namespace(buffer, hlCursorLine,0, -1)
		vim.api.nvim_buf_add_highlight(buffer, hlCursorLine, "PmenuSel", currentPosition , 0, -1)
		vim.cmd("normal! k0<CR>")
	else
		currentPosition = 0
		vim.api.nvim_buf_clear_namespace(buffer, hlCursorLine,0, -1)
		vim.api.nvim_buf_add_highlight(buffer, hlCursorLine, "PmenuSel", currentPosition , 0, -1)
	end

end

local function openWindow()

	currentPosition = 0
	local wrongWord = (vim.fn.spellbadword())[1]  -- get Currently misspelled Word
	local suggestionsSize

	if(wrongWord ~= "") then
		suggestions = vim.fn.spellsuggest(vim.fn.expand(wrongWord))
	else
		suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
	end

	if #suggestions > 10 then
		suggestionsSize = 10
	else
		suggestionsSize = #suggestions
	end

	if(suggestionsSize ~= 0 ) then
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_open_win(buf, true,
		{relative='cursor', row=1, col=0, width=40, height=suggestionsSize} )
		vim.wo.number = false
		vim.wo.relativenumber = false
		setKeymaps(buf, "false")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, suggestions)
		vim.api.nvim_buf_add_highlight(buf, hlCursorLine, "PmenuSel", currentPosition , 0, 40)
	else
		print("No Suggestions!")
	end

end

return {

	openWindow = openWindow,
	getSuggestion = getSuggestion,
	decrementHighlight = decrementHighlight,
	incrementHighlight = incrementHighlight,
	getMisspelledWords = getMisspelledWords,
}
