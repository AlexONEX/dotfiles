vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*", -- Apply whenever a colorscheme is loaded or changed
	callback = function()
		-- Define different styles for each heading level
		-- You can adjust 'fg' (foreground color), 'bold', 'italic', 'underline', 'bg' (background color)
		-- Use colors that fit your chosen colorscheme for a harmonious look.

		-- Example for H1: Bold, a distinct color (e.g., a strong primary color)
		vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#7AA6DA", bold = true }) -- Blue/Purple
		-- Or just @markup.heading.1 if the .markdown specific one doesn't show up

		-- Example for H2: Italic, a slightly less prominent color
		vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#A9B665", italic = true }) -- Green/Olive
		-- Or just @markup.heading.2

		-- Example for H3: Underline, a different distinct color
		vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#C8A0D8", underline = true }) -- Light Purple
		-- Or just @markup.heading.3

		-- You can continue this for H4, H5, H6 using other colors/styles
		-- E.g., vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#E6C87C" }) -- Yellow/Orange
		-- E.g., vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#B58DAE" }) -- Muted Pink
		-- E.g., vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#92CCB5" }) -- Light Teal

		-- If you still want the default 'Title' behavior for other things, but explicitly define headings,
		-- ensure that the default 'Title' highlight doesn't override these.
		-- Sometimes, you might need to link your custom groups back to some base
		-- if your colorscheme doesn't define enough distinct colors.
		-- For example:
		-- vim.api.nvim_set_hl(0, "Title", { link = "MyGeneralTitleColor" })
		-- vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { link = "MyHeading1Color" })
		-- This is more advanced; start with direct fg/bold/italic.
	end,
})
