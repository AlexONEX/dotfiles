require("git-conflict").setup({})

vim.api.nvim_create_autocmd("User", {
    pattern = "GitConflictResolved",
    callback = function()
        vim.schedule(function()
            vim.fn.setqflist({}, "r")
            vim.cmd([[GitConflictListQf]])
        end)
    end,
})
