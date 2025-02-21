require("config.lazy")

-- Sane options
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 100
vim.opt.foldtext = ""

vim.opt.breakindent = true
vim.opt.showmode = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search highlight" })

vim.keymap.set("n", "<leader>bx", "<cmd>source %<cr>", { desc = "Source current [B]uffer" })
vim.keymap.set("n", "<leader>x", ":.lua<cr>", { desc = "Evaluate current lua line" })
vim.keymap.set("v", "<leader>x", ":lua<cr>", { desc = "Evaluate current lua selection" })

-- Window navigation
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })

vim.keymap.set("t", "<escape><escape>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

vim.keymap.set(
	"n",
	"<leader>td",
	function()
		vim.diagnostic.enable(not vim.diagnostic.is_enabled())
	end,
	{ desc = "[T]oggle [D]iagnostics" }
)

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	desc = "Highlight yanked text for a short period of time",
	group = vim.api.nvim_create_augroup("__silver.highlight_yank", { clear = true }),
	callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
	desc = "Remove sign and number column from terminals",
	group = vim.api.nvim_create_augroup("__silver.remove_editor_columns_from_terminal", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.opt.signcolumn = "no"
	end,
})
