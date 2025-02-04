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
