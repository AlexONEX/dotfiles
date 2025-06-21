local base_capabilities = require("lsp.capabilities")
local on_attach = require("lsp.on_attach")
local lsp_utils = require("lsp.utils")
local general_utils = require("utils")

local server_configs_path = "lsp"
local server_files = vim.api.nvim_get_runtime_file(server_configs_path .. "/*.lua", true)
local available_servers = {}

for _, path in ipairs(server_files) do
	local server_name = vim.fn.fnamemodify(path, ":t:r")
	if
		server_name ~= "init"
		and server_name ~= "capabilities"
		and server_name ~= "on_attach"
		and server_name ~= "utils"
	then
		local success, config = pcall(require, server_configs_path .. "." .. server_name)
		if success then
			available_servers[server_name] = config
		else
			vim.notify("Error cargando config LSP: " .. server_name, vim.log.levels.ERROR, { title = "LSP Loader" })
		end
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	group = vim.api.nvim_create_augroup("J_LspAutoStart", { clear = true }),
	callback = function(args)
		local ft = args.match
		for server_name, server_config in pairs(available_servers) do
			if vim.tbl_contains(server_config.filetypes or {}, ft) then
				if not general_utils.executable(server_config.cmd[1]) then
					vim.notify(
						string.format("LSP no encontrado: %s", server_config.cmd[1]),
						vim.log.levels.WARN,
						{ title = server_name }
					)
					goto continue
				end

				local final_config = {
					name = server_name,
					cmd = server_config.cmd,
					filetypes = server_config.filetypes,
					init_options = server_config.init_options,
					root_dir = lsp_utils.find_root(server_config.root_markers or {}),
					capabilities = vim.tbl_deep_extend(
						"force",
						vim.deepcopy(base_capabilities),
						server_config.capabilities or {}
					),
					on_attach = on_attach,
				}

				vim.lsp.start(final_config)
				::continue::
			end
		end
	end,
})

vim.diagnostic.config({
	underline = true,
	virtual_text = {
		spacing = 4,
		prefix = "●",
	},
	signs = true,
	update_in_insert = false,
	severity_sort = true,
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
