local wezterm = require "wezterm"
local act = wezterm.action

local sessionizer = require "sessionizer"
local leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }

local keymaps = {
	{ key = "F11",           action = act.ToggleFullScreen },

	-- TMux keybindings
	{ mods = "LEADER",       key = "c",                    action = act.SpawnTab "CurrentPaneDomain" },
	{ mods = "LEADER",       key = "x",                    action = act.CloseCurrentPane { confirm = true } },
	{ mods = "LEADER",       key = "n",                    action = act.ActivateTabRelative(1) },
	{ mods = "LEADER",       key = "p",                    action = act.ActivateTabRelative(-1) },
	{ mods = "LEADER|SHIFT", key = "|",                    action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
	{ mods = "LEADER",       key = "-",                    action = act.SplitVertical { domain = "CurrentPaneDomain" } },

	-- Pane motion
	{ mods = "LEADER",       key = "j",                    action = act.ActivatePaneDirection "Down" },
	{ mods = "LEADER",       key = "k",                    action = act.ActivatePaneDirection "Up" },
	{ mods = "LEADER",       key = "h",                    action = act.ActivatePaneDirection "Left" },
	{ mods = "LEADER",       key = "l",                    action = act.ActivatePaneDirection "Right" },

	-- Pane size adjustment
	{ mods = "LEADER",       key = "LeftArrow",            action = act.AdjustPaneSize { "Left", 5 } },
	{ mods = "LEADER",       key = "RightArrow",           action = act.AdjustPaneSize { "Right", 5 } },
	{ mods = "LEADER",       key = "DownArrow",            action = act.AdjustPaneSize { "Down", 5 } },
	{ mods = "LEADER",       key = "UpArrow",              action = act.AdjustPaneSize { "Up", 5 } },

	{ mods = "LEADER",       key = "m",                    action = act.TogglePaneZoomState },
	{ mods = "LEADER",       key = "[",                    action = act.ActivateCopyMode },

	{ mods = "LEADER",       key = "t",                    action = wezterm.action_callback(sessionizer.open_todo) },
	{ mods = "LEADER",       key = "a",                    action = wezterm.action_callback(sessionizer.toggle) },
	{ mods = "LEADER|SHIFT", key = "$",                    action = wezterm.action_callback(sessionizer.rename_session) },

	{ mods = "LEADER",       key = "s",                    action = wezterm.action.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" }, },
	{ mods = "LEADER|SHIFT", key = ":",                    action = act.ActivateCommandPalette },
	{ mods = "LEADER",       key = "f",                    action = act.SwitchToWorkspace },
}

for i = 1, 9 do
	table.insert(keymaps, {
		mods = "LEADER",
		key = tostring(i),
		action = act.ActivateTab(i - 1),
	})
end

return {
	leader = leader,
	keymaps = keymaps,
}
