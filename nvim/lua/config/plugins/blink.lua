-- Mapping <C-D> to insert digraph mode
vim.keymap.set("i", "<C-D>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-K>", true, false, true), "n", true)
end, { noremap = true })

return {
	{
		"saghen/blink.cmp",
		version = "*",

		---@module "blink.cmp"
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "default" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "normal"
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" }
	}
}
