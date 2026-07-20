function init()
	local diffview = require "diffview"
	diffview.setup {}

	-- TODO: set some keymaps for diffview.nvim
end

return {
	{
		"sindrets/diffview.nvim",
		init = init,
	}
}
