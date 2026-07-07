-- Editor options (migrated from viml_conf/options.vim)
local opt = vim.opt
local o = vim.o
local wo = vim.wo

-- change fillchars for folding, vertical split, end of buffer, and message separator
opt.fillchars = {
  fold = " ",
  foldsep = " ",
  foldopen = "",
  foldclose = "",
  vert = "│",
  eob = " ",
  msgsep = "‾",
  diff = "╱",
}

-- Split window below/right when creating horizontal/vertical windows
opt.splitbelow = true
opt.splitright = true

-- avoid the flickering when splitting window horizontal
opt.splitkeep = "screen"

-- Time in milliseconds to wait for a mapped sequence to complete
opt.timeoutlen = 500

opt.updatetime = 500 -- For CursorHold events

-- Clipboard settings
if vim.fn.executable("pbcopy") == 1 or vim.fn.executable("xclip") == 1 or vim.fn.executable("wl-copy") == 1 then
  opt.clipboard:append("unnamedplus")
end

-- Disable creating swapfiles
opt.swapfile = false

-- Ignore certain files and folders when globing
opt.wildignore:append({ "*.o", "*.obj", "*.dylib", "*.bin", "*.dll", "*.exe" })
opt.wildignore:append({ "*/.git/*", "*/.svn/*", "*/__pycache__/*", "*/build/**" })
opt.wildignore:append({ "*.jpg", "*.png", "*.jpeg", "*.bmp", "*.gif", "*.tiff", "*.svg", "*.ico" })
opt.wildignore:append({ "*.pyc", "*.pkl" })
opt.wildignore:append({ "*.DS_Store" })
opt.wildignore:append({ "*.aux", "*.bbl", "*.blg", "*.brf", "*.fls", "*.fdb_latexmk", "*.synctex.gz", "*.xdv" })
opt.wildignorecase = true -- ignore file and dir name cases in cmd-completion

-- Set up backup directory
local backupdir = vim.fn.stdpath("data") .. "/backup//"
opt.backupdir = backupdir
opt.backupskip = vim.fn.split(vim.fn.execute("set wildignore?"), ",")
opt.backup = true -- create backup for files
opt.backupcopy = "yes" -- copy the original file to backupdir and overwrite it

-- General tab settings
opt.tabstop = 2 -- number of visual spaces per TAB
opt.softtabstop = 2 -- number of spaces in tab when editing
opt.shiftwidth = 2 -- number of spaces to use for autoindent
opt.expandtab = true -- expand tab to spaces so that tabs are spaces

-- Set matching pairs of characters and highlight matching brackets
opt.matchpairs:append({ "<:>", "「:」", "『:』", "【:】", "“:”", "‘:’", "《:》" })

opt.number = true
opt.relativenumber = true -- Show line number and relative line number

-- Ignore case in general, but become case-sensitive when uppercase is present
opt.ignorecase = true
opt.smartcase = true

-- File and script encoding settings
o.fileencoding = "utf-8"
opt.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"

-- Break line at predefined characters
opt.linebreak = true
-- Character to show before the lines that have been soft-wrapped
opt.showbreak = "↪"

-- List all matches and complete till longest common string
opt.wildmode = "list:longest"

-- Minimum lines to keep above and below cursor when scrolling
opt.scrolloff = 3

-- Use mouse to select and resize windows, etc.
opt.mouse = ""
opt.mousemodel = "popup" -- Set the behaviour of mouse
opt.mousescroll = "ver:1,hor:0"

-- Disable showing current mode on command line since statusline plugins can show it.
opt.showmode = false

opt.fileformats = "unix,dos" -- Fileformats to use for new files

-- Ask for confirmation when handling unsaved or read-only files
opt.confirm = true

opt.visualbell = true
opt.errorbells = false -- Do not use visual and errorbells
opt.history = 500 -- The number of command and search history to keep

-- Use list mode and customized listchars
opt.list = true
opt.listchars = { tab = "▸ ", extends = "❯", precedes = "❮", nbsp = "␣" }

-- Auto-write the file based on some condition
opt.autowrite = true

-- Show hostname, full path of file and last-mod time on the window title
opt.title = true
opt.titlestring = "%{v:lua.require('autoload').get_titlestr()}"

-- Persistent undo even after you close a file and re-open it
opt.undofile = true

-- Do not show "match xx of xx" and other messages during auto-completion
opt.shortmess:append("c")
-- Do not show search match count on bottom right
opt.shortmess:append("S")
-- Disable showing intro message
opt.shortmess:append("I")

opt.messagesopt = "wait:5000,history:500"

-- Completion behaviour
opt.completeopt:append("menuone") -- Show menu even if there is only one item
opt.completeopt:remove("preview") -- Disable the preview window

opt.pumheight = 10 -- Maximum number of items to show in popup menu
opt.pumblend = 5 -- pseudo transparency for completion menu

opt.winblend = 0 -- pseudo transparency for floating window
vim.o.winborder = "none"

-- Insert mode key word completion setting
-- Default is ".,w,b,u,t,i,kspell"; we remove slow sources (w,b,u,t) but keep .,i,kspell
opt.complete = ".,i,kspell"

opt.spelllang = { "en", "cjk" } -- Spell languages
opt.spellsuggest:append("9") -- show 9 spell suggestions at most

-- Align indent to next multiple value of shiftwidth
opt.shiftround = true

opt.virtualedit = "block" -- Virtual edit is useful for visual block edit

-- Correctly break multi-byte characters such as CJK
opt.formatoptions:append({ m = true, M = true })

-- Tilde (~) is an operator, thus must be followed by motions like `e` or `w`.
opt.tildeop = true

opt.synmaxcol = 250 -- Text after this column number is not highlighted
opt.startofline = false

-- External program to use for grep command
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Enable true color support
opt.termguicolors = true

-- Set up cursor color and shape in various mode
opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor20"

opt.signcolumn = "yes:1"

-- Remove certain character from file name pattern matching
opt.isfname:remove("=")
opt.isfname:remove(",")

-- diff options
opt.diffopt = {
  "vertical",
  "filler",
  "closeoff",
  "context:3",
  "internal",
  "indent-heuristic",
  "algorithm:histogram",
}
if vim.fn.has("nvim-0.12") == 1 then
  opt.diffopt:append("inline:char")
else
  opt.diffopt:append("linematch:60")
end

opt.wrap = false -- do not wrap
opt.ruler = false -- do not show ruler (statusline shows it)
