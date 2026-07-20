return {
	{
		"stevearc/oil.nvim",

		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},

		-- Optional dependencies
		dependencies = {
			"echasnovski/mini.icons",
			-- "nvim-tree/nvim-web-devicons",
		},

		lazy = false,

		init = function()
			vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open current file directory" })
		end,
	}
}
