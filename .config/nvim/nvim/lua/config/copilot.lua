require("copilot").setup({
	panel = {
		enabled = true,
		auto_refresh = false,
		keymap = {
			jump_prev = "[[",
			jump_next = "]]",
			accept = "<CR>",
			refresh = "gr",
			--open = "<M-CR>" -- Comentado ya que no está asignado a ninguna tecla actualmente
		},
		layout = {
			position = "bottom", -- Puede ser "top", "left" o "right"
			ratio = 0.4,
		},
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = "<M-l>",
			accept_word = "<M-w>", -- Agregado para aceptar sugerencias por palabra
			accept_line = "<M-L>", -- Agregado para aceptar sugerencias por línea
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
	},
	filetypes = {
		yaml = false,
		markdown = false,
		help = false,
		gitcommit = false,
		gitrebase = false,
		hgcommit = false,
		svn = false,
		cvs = false,
		["."] = false,
	},
	copilot_node_command = "node", -- Asegúrate de que Node.js sea la versión > 16.x
	server_opts_overrides = {},
})
