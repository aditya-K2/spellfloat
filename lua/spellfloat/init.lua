SelectedWordSuggestion = ""
local hlCursorLine = vim.api.nvim_create_namespace("CursorLine")
local currentPosition = 0
local suggestionsSize

local function getSuggestion()

	SelectedWordSuggestion = vim.api.nvim_get_current_line()
	vim.cmd("q!")
	vim.cmd("normal! ciw" .. SelectedWordSuggestion)

end

local function incrementHighlight(buffer)

	vim.cmd("normal! j0<CR>")
	if currentPosition>=0 then
		currentPosition = currentPosition + 1
	else
		currentPosition = 0
	end
	vim.api.nvim_buf_clear_namespace(buffer, hlCursorLine,0, -1)
	vim.api.nvim_buf_add_highlight(buffer, hlCursorLine, "PmenuSel", currentPosition , 0, -1)

end

local function decrementHighlight(buffer)

	vim.cmd("normal! k0<CR>")
	if currentPosition < suggestionsSize then
		currentPosition = currentPosition - 1
	else
		currentPosition = suggestionsSize
	end
	vim.api.nvim_buf_clear_namespace(buffer, hlCursorLine,0, -1)
	vim.api.nvim_buf_add_highlight(buffer, hlCursorLine, "PmenuSel", currentPosition , 0, -1)

end

local function openWindow()

	currentPosition = 0
	local wrongWord = (vim.fn.spellbadword())[1]  -- get Currently misspelled Word
	local suggestions = ""

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

		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_open_win(buf, true,
		  {relative='cursor', row=1, col=0, width=40, height=suggestionsSize} )
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.api.nvim_buf_set_keymap(buf, 'n', "<CR>", ":<cmd> lua require('spellfloat').getSuggestion()<CR><CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, 'n', "<Space>", ":<cmd> lua require('spellfloat').getSuggestion()<CR><CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, 'n', "<Tab>", ":<cmd> lua require('spellfloat').incrementHighlight()<CR><CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, 'n', "<S-Tab>", ":<cmd> lua require('spellfloat').decrementHighlight()<CR><CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, 'n', "<Esc>", ":q!<CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, suggestions)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, suggestions)
		vim.api.nvim_buf_add_highlight(buf, hlCursorLine, "PmenuSel", currentPosition , 0, 40)

end

return {
	openWindow = openWindow,
	getSuggestion = getSuggestion,
	decrementHighlight = decrementHighlight,
	incrementHighlight = incrementHighlight
}
