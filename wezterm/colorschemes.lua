local NVIM_DARK = {
	colors = {
		ansi = {
			"#07080d",
			"#ffc0b9",
			"#b3f6c0",
			"#fce094",
			"#a6dbff",
			"#ffcaff",
			"#8cf8f7",
			"#eef1f8",
		},
		background = "#14161b",
		brights = {
			"#4f5258",
			"#ffc0b9",
			"#b3f6c0",
			"#fce094",
			"#a6dbff",
			"#ffcaff",
			"#8cf8f7",
			"#eef1f8",
		},
		cursor_bg = "#9b9ea4",
		cursor_border = "#9b9ea4",
		cursor_fg = "#e0e2ea",
		foreground = "#e0e2ea",
		indexed = {},
		selection_bg = "#4f5258",
		selection_fg = "#e0e2ea",
	},
	metadata = {
		aliases = {},
		name = "NvimDark",
		origin_url = "https://github.com/mbadolato/iTerm2-Color-Schemes",
		prefix = "n",
		wezterm_version = "nightly builds only",
	}
}

local NVIM_LIGHT = {
	colors = {
		ansi = {
			"#07080d",
			"#590008",
			"#005523",
			"#6b5300",
			"#004c73",
			"#470045",
			"#007373",
			"#eef1f8",
		},
		background = "#e0e2ea",
		brights = {
			"#4f5258",
			"#590008",
			"#005523",
			"#6b5300",
			"#004c73",
			"#470045",
			"#007373",
			"#eef1f8",
		},
		cursor_bg = "#9b9ea4",
		cursor_border = "#9b9ea4",
		cursor_fg = "#14161b",
		foreground = "#14161b",
		indexed = {},
		selection_bg = "#9b9ea4",
		selection_fg = "#14161b",
	},
	metadata = {
		aliases = {},
		name = "NvimLight",
		origin_url = "https://github.com/mbadolato/iTerm2-Color-Schemes",
		prefix = "n",
		wezterm_version = "nightly builds only",
	}
}

return {
	NVIM_DARK = NVIM_DARK,
	NVIM_LIGHT = NVIM_LIGHT,
}
