local DEFAULT_PARSERS = {
	"bash",
	"c",
	"cpp",
	"css",
	"glsl",
	"html",
	"java",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"rust",
	"ssh_config",
	"toml",
	"tsx",
	"typescript",
	"typst",
	"vim",
	"vimdoc",
	"wgsl",
	"xml",
	"yaml",
}


local function config()
	require("nvim-treesitter.configs").setup {
		ensure_installed = DEFAULT_PARSERS,
		auto_install = false,
		highlight = {
			enable = true,
			disable = function(lang, buf)
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
			additional_vim_regex_highlighting = false,
		},
	}
end


return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = config,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		init = function()
			require("treesitter-context").setup {
				enable = true,
				multiwindow = false,
				max_lines = 0,
				min_window_height = 0,
				line_numbers = true,
				multiline_threshold = 20,
				trim_scope = 'outer',
				mode = 'cursor',
				separator = nil,
				zindex = 20,
				on_attach = nil,
			}
			vim.keymap.set(
				"n",
				"[C",
				function() require("treesitter-context").go_to_context(vim.v.count1) end,
				{ silent = true, desc = "Jump to current [C]ontext" }
			)
		end,
	}
}
