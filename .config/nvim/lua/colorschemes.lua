local utils = require("utils")
local M = {}

-- Colorscheme to its directory name mapping, because colorscheme repo name is not necessarily
-- the same as the colorscheme name itself.
M.colorscheme_conf = {
	onedark = function()
		vim.cmd([[colorscheme onedark]])
	end,
	edge = function()
		vim.g.edge_enable_italic = 1
		vim.g.edge_better_performance = 1
		vim.cmd([[colorscheme edge]])
	end,
	sonokai = function()
		vim.g.sonokai_enable_italic = 1
		vim.g.sonokai_better_performance = 1
		vim.cmd([[colorscheme sonokai]])
	end,
	gruvbox_material = function()
		-- foreground option can be material, mix, or original
		vim.g.gruvbox_material_foreground = "original"
		--background option can be hard, medium, soft
		vim.g.gruvbox_material_background = "medium"
		vim.g.gruvbox_material_enable_italic = 1
		vim.g.gruvbox_material_better_performance = 1
		vim.cmd([[colorscheme gruvbox-material]])
	end,
	everforest = function()
		vim.g.everforest_enable_italic = 1
		vim.g.everforest_better_performance = 1
		vim.cmd([[colorscheme everforest]])
	end,
	nightfox = function()
		vim.cmd([[colorscheme nordfox]])
	end,
	catppuccin = function()
		-- available option: latte, frappe, macchiato, mocha
		vim.g.catppuccin_flavour = "frappe"
		require("catppuccin").setup()
		vim.cmd([[colorscheme catppuccin]])
	end,
	onedarkpro = function()
		-- set colorscheme after options
		vim.cmd("colorscheme onedark_vivid")
	end,
	material = function()
		vim.g.material_style = "oceanic"
		vim.cmd("colorscheme material")
	end,
	arctic = function()
		vim.cmd("colorscheme arctic")
	end,
	kanagawa = function()
		vim.cmd("colorscheme kanagawa-wave")
	end,
	nord = function()
		vim.cmd("colorscheme nord")
	end,
}

-- Function to load a specific colorscheme
M.load_colorscheme = function(colorscheme)
	if type(colorscheme) ~= "string" then
		local msg = "Invalid colorscheme type: " .. type(colorscheme)
		vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
		return
	end

	if M.colorscheme_conf[colorscheme] then
		local status, err = pcall(M.colorscheme_conf[colorscheme])
		if status then
			if vim.g.logging_level == "debug" then
				local msg = "Colorscheme loaded: " .. colorscheme
				vim.notify(msg, vim.log.levels.DEBUG, { title = "nvim-config" })
			end
		else
			local msg = "Error loading colorscheme " .. colorscheme .. ": " .. err
			vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
		end
	else
		local msg = "Colorscheme not found: " .. colorscheme
		vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
	end
end

--- Use a random colorscheme from the pre-defined list of colorschemes.
M.rand_colorscheme = function()
	local colorscheme = utils.rand_element(vim.tbl_keys(M.colorscheme_conf))
	M.load_colorscheme(colorscheme)
end

-- Load a random colorscheme
--M.rand_colorscheme()
M.load_colorscheme("nord")
return M
