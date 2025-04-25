local api = vim.api
local keymap = vim.keymap
local utils = require("utils")

-- This module configures Neorg for LaTeX notes and presentations
local M = {}

function M.setup()
	-- Check if neorg is available
	local has_neorg, neorg = pcall(require, "neorg")
	if not has_neorg then
		vim.notify("neorg not found!", vim.log.levels.WARN, { title = "Nvim-config" })
		return
	end

	-- Path configuration for workspaces
	local neorg_dir = vim.fn.expand("~/Documents/notes")
	local work_dir = vim.fn.expand("~/Documents/notes/work")
	local personal_dir = vim.fn.expand("~/Documents/notes/personal")
	local presentations_dir = vim.fn.expand("~/Documents/notes/presentations")

	-- Create the directories if they don't exist
	for _, dir in ipairs({ neorg_dir, work_dir, personal_dir, presentations_dir }) do
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end

	-- Set up Neorg with minimal configuration first to ensure it works
	neorg.setup({
		load = {
			["core.defaults"] = {}, -- Loads default modules
			["core.dirman"] = {
				config = {
					workspaces = {
						main = neorg_dir,
						work = work_dir,
						personal = personal_dir,
						presentations = presentations_dir,
					},
					default_workspace = "main",
				},
			},
		},
	})

	-- Define basic keybindings manually (avoiding core.keybinds module for now)
	api.nvim_create_autocmd("FileType", {
		pattern = "norg",
		callback = function()
			-- Set buffer-local keymaps
			local map = function(mode, lhs, rhs, desc)
				keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
			end

			-- Basic navigation commands
			map("n", "<Leader>nn", ":Neorg workspace main<CR>", "Switch to main workspace")
			map("n", "<Leader>nw", ":Neorg workspace work<CR>", "Switch to work workspace")
			map("n", "<Leader>np", ":Neorg workspace presentations<CR>", "Switch to presentations workspace")

			-- Export commands (if available)
			map("n", "<Leader>nm", ":Neorg export to-file %:p.md markdown<CR>", "Export to Markdown")

			-- Only add these if the commands are registered
			if vim.fn.exists(":Neorg presenter start") == 2 then
				map("n", "<Leader>ns", ":Neorg presenter start<CR>", "Start presenter mode")
			end
		end,
		desc = "Configure basic Neorg keymaps",
	})

	-- Add custom commands for creating new notes
	api.nvim_create_user_command("NeorgNote", function()
		local filename = vim.fn.input("Enter note filename (without extension): ")
		if filename == "" then
			return
		end

		local filepath = neorg_dir .. "/" .. filename .. ".norg"
		vim.cmd("edit " .. filepath)

		-- Add template for new files
		if vim.fn.filereadable(filepath) == 0 then
			local template = {
				"* " .. filename,
				"",
				"** Introduction",
				"",
				"Your notes here",
				"",
			}

			api.nvim_buf_set_lines(0, 0, 0, false, template)
			vim.cmd("write")
		end
	end, {})

	-- Set up template for presentation slides
	api.nvim_create_user_command("NeorgSlide", function()
		-- Create a new presentation slide
		local filename = vim.fn.input("Enter slide filename (without extension): ")
		if filename == "" then
			return
		end

		local filepath = presentations_dir .. "/" .. filename .. ".norg"
		vim.cmd("edit " .. filepath)

		-- If file is new, add slide template
		if vim.fn.filereadable(filepath) == 0 then
			local template = {
				"@document.meta",
				"title: " .. filename,
				"description: Presentation created with Neorg",
				"authors: [Your Name]",
				"date: " .. os.date("%Y-%m-%d"),
				"categories: [presentation, slides]",
				"version: 1.0.0",
				"@end",
				"",
				"* " .. filename,
				"",
				"** Slide 1: Introduction",
				"",
				"Your content here",
				"",
				"---",
				"",
				"** Slide 2: Main Content",
				"",
				"More content here",
				"",
				"---",
				"",
				"** Slide 3: Conclusion",
				"",
				"Conclusion here",
			}

			api.nvim_buf_set_lines(0, 0, 0, false, template)
			vim.cmd("write")
		end
	end, {})

	-- Set up template for LaTeX notes
	api.nvim_create_user_command("NeorgLatexNote", function()
		-- Create a new LaTeX-oriented note
		local filename = vim.fn.input("Enter note filename (without extension): ")
		if filename == "" then
			return
		end

		local filepath = work_dir .. "/" .. filename .. ".norg"
		vim.cmd("edit " .. filepath)

		-- If file is new, add LaTeX note template
		if vim.fn.filereadable(filepath) == 0 then
			local template = {
				"@document.meta",
				"title: " .. filename,
				"description: LaTeX-oriented note",
				"authors: [Your Name]",
				"date: " .. os.date("%Y-%m-%d"),
				"categories: [notes, latex]",
				"version: 1.0.0",
				"@end",
				"",
				"* " .. filename,
				"",
				"** Introduction",
				"",
				"Your introduction here",
				"",
				"** Mathematical Content",
				"",
				"@math",
				"f(x) = \\int_{-\\infty}^{\\infty} \\hat{f}(\\xi)\\,e^{2 \\pi i \\xi x} \\,d\\xi",
				"@end",
				"",
				"** Conclusion",
				"",
				"Your conclusion here",
			}

			api.nvim_buf_set_lines(0, 0, 0, false, template)
			vim.cmd("write")
		end
	end, {})

	-- Command to compile to PDF via Markdown and Pandoc
	api.nvim_create_user_command("NeorgCompilePDF", function()
		-- Get current file path
		local current_file = vim.fn.expand("%:p")

		-- Check if this is a Neorg file
		if vim.fn.fnamemodify(current_file, ":e") ~= "norg" then
			vim.notify("Current file is not a Neorg file!", vim.log.levels.ERROR, { title = "Neorg Compiler" })
			return
		end

		-- Export to Markdown
		vim.cmd("Neorg export to-file " .. current_file .. ".md markdown")

		-- Get the Markdown file path
		local md_file = current_file .. ".md"

		-- Check if the Markdown file exists
		if vim.fn.filereadable(md_file) == 0 then
			vim.notify(
				"Export failed or file not found: " .. md_file,
				vim.log.levels.ERROR,
				{ title = "Neorg Compiler" }
			)
			return
		end

		-- Check if pandoc is installed
		if not utils.executable("pandoc") then
			vim.notify(
				"Pandoc not found! Please install pandoc to compile to PDF.",
				vim.log.levels.ERROR,
				{ title = "Neorg Compiler" }
			)
			return
		end

		-- Compile Markdown to PDF using pandoc
		local pdf_file = vim.fn.fnamemodify(md_file, ":r") .. ".pdf"
		local compile_cmd = "pandoc -f markdown -t pdf "
			.. vim.fn.shellescape(md_file)
			.. " -o "
			.. vim.fn.shellescape(pdf_file)
			.. " --pdf-engine=xelatex -V mainfont='DejaVu Sans' -V monofont='DejaVu Sans Mono' -V 'geometry:margin=1in' -V colorlinks=true"

		vim.notify("Compiling to PDF...", vim.log.levels.INFO, { title = "Neorg Compiler" })

		vim.fn.jobstart(compile_cmd, {
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					vim.notify(
						"Successfully compiled to PDF: " .. pdf_file,
						vim.log.levels.INFO,
						{ title = "Neorg Compiler" }
					)

					-- Ask if user wants to open the PDF
					vim.ui.select({ "Yes", "No" }, {
						prompt = "Open the PDF?",
					}, function(choice)
						if choice == "Yes" then
							local open_cmd
							if vim.fn.has("mac") == 1 then
								open_cmd = "open "
							elseif vim.fn.has("unix") == 1 then
								open_cmd = "xdg-open "
							elseif vim.fn.has("win32") == 1 then
								open_cmd = "start "
							end

							if open_cmd then
								vim.fn.jobstart(open_cmd .. vim.fn.shellescape(pdf_file))
							end
						end
					end)
				else
					vim.notify(
						"Failed to compile PDF. Exit code: " .. exit_code,
						vim.log.levels.ERROR,
						{ title = "Neorg Compiler" }
					)
				end
			end,
		})
	end, {})

	-- Configure custom highlights for Neorg
	api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			-- Custom highlights for better math representation
			vim.cmd([[
                hi! link NeorgMath ModeMsg
                hi! link NeorgHeading1 Title
                hi! link NeorgHeading2 Function
                hi! link NeorgHeading3 Identifier
                hi! link NeorgHeading4 String
                hi! link NeorgTodo Todo
                hi! link NeorgTodoItem1Done DiagnosticOk
                hi! link NeorgTodoItem1Pending DiagnosticWarn
                hi! link NeorgTodoItem1Undone DiagnosticError
            ]])
		end,
		nested = true,
		desc = "Configure Neorg-specific highlights",
	})
end

return M
