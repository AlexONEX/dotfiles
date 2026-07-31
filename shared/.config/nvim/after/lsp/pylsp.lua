-- Runs alongside pyright/ruff purely for rope refactoring code actions.
-- Everything that pyright or ruff handles is disabled to avoid duplicates.
return {
  cmd = { "pylsp" },
  filetypes = { "python" },
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        mccabe = { enabled = false },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        flake8 = { enabled = false },
        pylint = { enabled = false },
        jedi_completion = { enabled = false },
        jedi_hover = { enabled = false },
        jedi_references = { enabled = false },
        jedi_signature_help = { enabled = false },
        jedi_symbols = { enabled = false },
        rope_autoimport = { enabled = false },
        rope_completion = { enabled = false },
        -- pylsp_rope is auto-discovered; provides extract/inline/organize code actions
      },
    },
  },
}
