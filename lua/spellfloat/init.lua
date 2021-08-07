SelectedWordSuggestion = ""

local function getSuggestion()
	SelectedWordSuggestion = vim.api.nvim_get_current_line()
	vim.cmd("q!")
	vim.cmd("normal! caw" .. SelectedWordSuggestion)
end

local function openWindow()

	local wrongWord = (vim.fn.spellbadword())[1]
	if(wrongWord ~= "") then
		local suggestions = vim.fn.spellsuggest(vim.fn.expand(wrongWord))
		local buf = vim.api.nvim_create_buf(false, true)
		local winId = vim.api.nvim_open_win(buf, true,
		  {relative='cursor', row=0, col=0, width=40, height=10} )
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.api.nvim_buf_set_lines(buf, 1, -1, false, suggestions)
	end

end

return {
	openWindow = openWindow,
	getSuggestion = getSuggestion,
}
