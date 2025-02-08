local function init()
	local statusline = require "mini.statusline"
	statusline.setup {
		use_icons = true,
	}

	require("mini.ai").setup {}
	require("mini.jump").setup {}
	require("mini.jump2d").setup {}
	require("mini.move").setup {}
	require("mini.surround").setup {}
	require("mini.pairs").setup {}

	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = "rust",
		group = vim.api.nvim_create_augroup("__silver.rust_disable_single_quote_pairs", { clear = true }),
		desc = "Disabling single quote auto-pairing for rust",
		callback = function()
			vim.keymap.set("i", "'", "'", { buffer = true })
		end
	})
end

return {
	{
		"echasnovski/mini.nvim",
		init = init,
	},
}
