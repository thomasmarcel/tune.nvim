local M = {}

-- Define the path to the colorschemes directory
local colorschemePath = vim.fn.expand("~/.config/nvim/lua/custom/plugins/colorschemes/")

-- Load colorschemes from the colorschemes directory
local function loadColorschemes()
	local dir = vim.fn.expand("~/.config/nvim/lua/custom/plugins/colorschemes/")
	local colorschemes = {}

	-- Iterate over files in the colorschemes directory
	for _, entry in ipairs(vim.fn.readdir(dir)) do
		local path = dir .. "/" .. entry
		local is_dir = vim.fn.isdirectory(path) == 1

		-- Extract colorscheme name from directories or valid vim files
		local colorscheme = is_dir and entry or entry:match("^(.+)%..-$")

		-- If directory name is in "vim-<colorscheme>", use <colorscheme> as the colorscheme name
		if is_dir and colorscheme:match("^vim%-(.+)$") then
			colorscheme = colorscheme:match("^vim%-(.+)$")
		end

		-- Append colorscheme name to the list
		if colorscheme then
			table.insert(colorschemes, colorscheme)
		end
	end

	return colorschemes
end

-- Create the default colorscheme object
local function createDefaultObject()
	local default = {
		font = "default",
		background = "dark",
		fontSize = 12,
	}
	return default
end

-- Set the colorscheme, font, background, and font size
function M.setTheme(theme, font, background, fontSize)
	theme = theme or ""
	font = font or ""
	background = background or ""
	fontSize = fontSize or 0
	vim.cmd("colorscheme " .. theme)
	vim.o.guifont = font
	if vim.fn.has("gui_running") == 1 then
		vim.o.guifontsize = fontSize
	end
end

-- Command to set the theme with autocompletion
local function setThemeCommand(theme)
	local mapping = string.format("<cmd>lua require('tune').setTheme('%s', '', '', 0)<CR>", theme)
	vim.cmd(
		string.format(
			"command! -nargs=1 -complete=customlist,v:lua.require('tune').completeColorschemes Tune lua require('tune').setTheme(<f-args>)",
			theme
		)
	)
	vim.api.nvim_set_keymap("n", "<Leader>t" .. theme, mapping, { silent = true })
end

-- Custom completion function for colorschemes
function M.completeColorschemes(arglead, cmdline, cursorpos)
	-- print(arglead, cmdline, cursorpos)
	local debug_message = string.format("Complete Colorschemes: %s %s %d", arglead, cmdline, cursorpos)
	vim.api.nvim_echo({ { debug_message, "Normal" } }, true, {})
	local colorschemes = loadColorschemes()
	local matches = {}
	for _, scheme in ipairs(colorschemes) do
		if scheme:find(arglead) == 1 then
			table.insert(matches, scheme)
		end
	end
	table.sort(matches)
	return matches
end

-- Plugin setup function
function M.setup()
	-- Load colorschemes
	local colorschemes = loadColorschemes()

	-- Create default colorscheme object
	local defaultObject = createDefaultObject()

	-- Add commands for each colorscheme
	for _, theme in ipairs(colorschemes) do
		setThemeCommand(theme)
	end

	-- Add a command to set the theme with custom settings
	vim.cmd([[
    command! -nargs=* -complete=customlist,v:lua.require('tune').completeColorschemes Tune lua require('tune').setTheme(<f-args>)
  ]])

	-- Set the default colorscheme
	M.setTheme(colorschemes[1], defaultObject.font, defaultObject.background, defaultObject.fontSize)
end

return M
