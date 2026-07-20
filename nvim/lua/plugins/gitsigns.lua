function init()
	local gitsigns = require "gitsigns"

	gitsigns.setup {}

	vim.keymap.set(
		"v",
		"<leader>hs",
		function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
		{ desc = "git [S]tage [H]unk" }
	)
	vim.keymap.set(
		"v",
		"<leader>hr",
		function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
		{ desc = "git [R]eset [H]unk" }
	)

	vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [S]tage [H]unk" })
	vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [R]eset [H]unk" })
	vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
	vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
	vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [P]review [H]unk" })
	vim.keymap.set(
		"n",
		"<leader>hb",
		function() gitsigns.blame_line { full = false } end,
		{ desc = "git [B]lame line" }
	)
	vim.keymap.set(
		"n",
		"<leader>tb",
		gitsigns.toggle_current_line_blame,
		{ desc = "git [T]oggle [B]lame line" }
	)
end

return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = '+' },
				change = { text = '~' },
				delete = { text = '_' },
				topdelete = { text = '‾' },
				changedelete = { text = '~' },
			},
		},
		init = init,
	},
}
