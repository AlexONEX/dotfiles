require("lint").linters_by_ft = {
	markdown = { "vale" },
	python = { "ruff" }, -- Python linters
	yaml = { "yamllint" }, -- YAML linter
	tex = { "chktex" }, -- LaTeX linter
	c = { "clangtidy" }, -- C linter
	cpp = { "clangtidy" }, -- C++ linter
	javascript = { "eslint" }, -- JavaScript linter
	typescript = { "eslint" }, -- TypeScript linter
	scala = { "scalafmt" }, -- Scala linter
}

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*",
	callback = function()
		require("lint").try_lint()
	end,
})

local lint_progress = function()
	local linters = require("lint").get_running()
	if #linters == 0 then
		return "󰦕"
	end
	return "󱉶 " .. table.concat(linters, ", ")
end
