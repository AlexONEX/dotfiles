return {
  "kelly-lin/ranger.nvim",
  config = function()
    require("ranger-nvim").setup({ replace_netrw = true })
    vim.api.nvim_set_keymap("n", "<leader>ef", "", {
      noremap = true,
      callback = function()
        require("ranger-nvim").open(true)
        vim.g.rnvimr_enable_picker = 1
        vim.g.enable_ex = 1
        vim.g.rnvimr_edit_cmd = "drop"
        vim.g.rnvimr_draw_border = 0
        vim.g.rnvimr_border_attr = { ["fg"] = 14, ["bg"] = -1 }
        vim.g.rnvimr_enable_bw = 1
        vim.g.rnvimr_shadow_winblend = 70
        vim.g.rnvimr_action = {
          ["<C-t>"] = "NvimEdit tabedit",
          ["<C-x>"] = "NvimEdit split",
          ["<C-v>"] = "NvimEdit vsplit",
          ["gw"] = "JumpNvimCwd",
          ["yw"] = "EmitRangerCwd",
        }
      end,
    })
  end,
}
