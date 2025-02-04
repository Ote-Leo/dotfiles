local wezterm = require "wezterm"
local keybindings = require "keybindings"

---@param window wezterm.Window
---@param pane wezterm.Pane
local function set_right_status(window, pane)
	local cells = {}

	local workspace = window:active_workspace() or "???"
	local date = wezterm.strftime "%a %b %-d %H:%M"

	table.insert(cells, workspace)
	table.insert(cells, wezterm.hostname())
	table.insert(cells, date)

	-- An entry for each battery (typically 0 or 1 battery)
	for _, b in ipairs(wezterm.battery_info()) do
		table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
	end

	local LEFT_ARROW = utf8.char(0xE0B3)
	local SOLID_LEFT_ARROW = utf8.char(0xE0B2)

	local colors = {
		"#3C1361",
		"#52307C",
		"#663A82",
		"#7C5295",
		"#B491C8",
	}

	local text_fg = "#C0C0C0"
	local elements = {}
	local num_cells = 0

	function push(text, is_last)
		local cell_no = num_cells + 1
		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
		end
		num_cells = num_cells + 1
	end

	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end

	window:set_right_status(wezterm.format(elements))
end

wezterm.on("update-status", set_right_status)

wezterm.on(
	"update-right-status",
	function(window, pane)
		local solid_left_arrow = ""
		local arrow_foreground = { Foreground = { Color = "#C6A0F6" } }
		local prefix = ""

		if window:leader_is_active() then
			prefix = " " .. utf8.char(0x1F30A) -- ocean wave
			solid_left_arrow = utf8.char(0xE0B2)
		end

		if window:active_tab():tab_id() ~= 0 then
			arrow_foreground = { Foreground = { color = "#1E2030" } }
		end -- arrow color based on if tab is first pane

		window:set_left_status(wezterm.format {
			{ Background = { Color = "#B6BDF8" } },
			{ Text = prefix },
			arrow_foreground,
			{ Text = solid_left_arrow },
		})
	end
)

local config = wezterm.config_builder()

config.font = wezterm.font { family = "FiraCode Nerd Font" }
config.color_scheme = "rose-pine"
config.default_prog = { "nu" }

config.leader = keybindings.leader
config.keys = keybindings.keymaps

config.show_tabs_in_tab_bar = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = true
config.tab_bar_at_bottom = true

return config
