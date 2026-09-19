return {
  -- terraform-ls dumps its full RPC log to stderr, which nvim tags as [ERROR]
  -- and floods lsp.log (7k+ lines). Redirect that log to /dev/null; real
  -- startup failures still surface via the LSP client itself.
  -- ponytail: /dev/null drops all server logs; point at a file if you ever need them.
  cmd = { "terraform-ls", "serve", "-log-file", "/dev/null" },
  filetypes = { "terraform", "terraform-vars" },
}
