local M = {}

M.get_default_capabilities = function()
	local capabilities = vim.lsp.protocol.make_client_capabilities()

	-- required by nvim-ufo
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	return capabilities
end

function M.find_root(markers)
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		return nil
	end

	local dir = vim.fn.fnamemodify(file_path, ":h")
	local root = vim.fs.find(markers, { path = dir, upward = true })[1]
	return root
end

function show_active_lsps()
	local clients = vim.lsp.get_active_clients({ bufnr = 0 })

	if vim.tbl_isempty(clients) then
		vim.notify("No hay clientes LSP activos para este buffer.", vim.log.levels.INFO)
		return
	end

	local client_names = {}
	for _, client in ipairs(clients) do
		table.insert(client_names, client.name)
	end

	vim.notify("Active LSPs: " .. table.concat(client_names, ", "), vim.log.levels.INFO)
end

-- define command to show active LSPs
vim.api.nvim_create_user_command("LspInfo", show_active_lsps, {})

return M
