return {
	{
		"echasnovski/mini.nvim",
		config = function()
			local statusline = require "mini.statusline"

			statusline.setup {
				use_icons = true,
			}

			require("mini.ai").setup()
			require("mini.jump").setup()
			require("mini.jump2d").setup()
			require("mini.move").setup()
			require("mini.pairs").setup()
			require("mini.surround").setup()
		end,
	},
}
