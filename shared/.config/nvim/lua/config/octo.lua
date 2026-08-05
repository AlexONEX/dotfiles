local comment_maps = {
  add_comment = { lhs = "<localleader>ga", desc = "add comment" },
  add_reply = { lhs = "<localleader>gr", desc = "add reply" },
  delete_comment = { lhs = "<localleader>gd", desc = "delete comment" },
  comment_edits = { lhs = "<localleader>ge", desc = "show comment edit history" },
}

require("octo").setup {
  picker = "snacks",
  use_local_fs = false,
  suppress_missing_scope = {
    projects_v2 = true,
  },
  mappings = {
    discussion = comment_maps,
    issue = comment_maps,
    pull_request = comment_maps,
    review_thread = comment_maps,
    review_diff = {
      add_review_comment = { lhs = "<localleader>ga", desc = "add a new review comment", mode = { "n", "x" } },
    },
  },
}
