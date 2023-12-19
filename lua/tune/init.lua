local M = {}

local function set_default_colorscheme(default_scheme)
	if default_scheme then
		vim.cmd("colorscheme " .. default_scheme)
	end
end

function M.setup(config)
	config = config or {}

	-- Set default colorscheme from configuration or use a default one
	set_default_colorscheme(config.default_colorscheme or "default")

	-- Function to get the list of available colorschemes using the API
	function M.get_available_colorschemes()
		local runtime_paths = vim.api.nvim_list_runtime_paths()

		local colorschemes = {}

		for _, path in ipairs(runtime_paths) do
			local colors_path = path .. "/colors"
			local colors = vim.fn.glob(colors_path .. "/*.vim", false, true)
			for _, color in ipairs(colors) do
				local colorscheme = vim.fn.fnamemodify(color, ":t:r")
				table.insert(colorschemes, colorscheme)
			end
		end

		return colorschemes
	end

	-- Function to set a colorscheme
	function M.set_colorscheme(colorscheme)
		vim.cmd("colorscheme " .. vim.trim(colorscheme))
	end

	-- Function to pick a random colorscheme
	function M.pick_random_colorscheme()
		local colorschemes = M.get_available_colorschemes()
		local random_index = math.random(1, #colorschemes)
		local random_colorscheme = colorschemes[random_index]
		M.set_colorscheme(random_colorscheme)
	end

	-- Define Neovim commands
	vim.cmd('command! -nargs=1 Tune lua require("tune").set_colorscheme(<q-args>)')
	vim.cmd('command! TuneRandom lua require("tune").pick_random_colorscheme()')
end

return M
