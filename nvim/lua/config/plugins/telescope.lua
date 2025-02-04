local multi_grep = require "config.telescope.multi_grep"

local FZF_NATIVE_BUILD_COMMAND = "make"

if vim.fn.has "win32" then
	FZF_NATIVE_BUILD_COMMAND = (
		"cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
		.. "cmake --build build --config Release && "
		.. "cmake --install build --prefix build"
	)
end


local DEPENDENCIES = {
	"nvim-lua/plenary.nvim",
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = FZF_NATIVE_BUILD_COMMAND,
	},
}

local function search_config_files()
	require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end

local function search_pacakges_files()
	---@type string
	local data_path = vim.fn.flatten({ vim.fn.stdpath("data") })[1]

	require("telescope.builtin").find_files({
		cwd = vim.fs.joinpath(data_path, "lazy")
	})
end

local function init()
	local telescope = require "telescope"
	telescope.setup {
		extensions = {
			fzf = {},
		},
	}
	telescope.load_extension "fzf"

	local builtin = require "telescope.builtin"

	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Search open buffers" })
	vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find current buffer" })
	vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch builtin telescope [S]earchers" })
	vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch Workspace [F]iles" })
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp tags" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>sp", search_pacakges_files, { desc = "[S]earch [P]acakges files" })

	vim.keymap.set("n", "<leader>s/", function()
		builtin.live_grep {
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		}
	end, { desc = "[S]earch [/] in Open Files" })

	-- Shortcut for searching your Neovim configuration files
	vim.keymap.set("n", "<leader>sn", function()
		builtin.find_files { cwd = vim.fn.stdpath "config" }
	end, { desc = "[S]earch [N]eovim files" })

	multi_grep.setup()
end


return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = DEPENDENCIES,
		init = init,
	}
}
