local wezterm = require "wezterm"
local util = require "util"
local act = wezterm.action
local targets = require "sessionizer_targets"

local M = {}

M.open_todo = function(window, pane)
	local todo_file = targets.todo_file
	if not todo_file then
		return
	end
	window:perform_action(act.SpawnCommandInNewTab { args = { "nvim", todo_file } }, pane)
end

M.toggle = function(window, pane)
	local projects = {}

	local command = util.extend({
		"fd",
		"-HI",
		"-td",
		"^.git$",
		"--max-depth=2",
	}, targets.paths or {})

	local success, stdout, stderr = wezterm.run_child_process(command)

	if not success then
		wezterm.log_error("Failed to run fd: " .. stderr)
		return
	end

	for line in stdout:gmatch("([^\n]*)\n?") do
		local project = line:gsub([=[[\/].git[\/]$]=], "")
		local label = project
		local id = project:gsub([=[.*[\/]]=], "")
		table.insert(projects, { label = tostring(label), id = tostring(id) })
	end

	window:perform_action(
		act.InputSelector {
			action = wezterm.action_callback(function(win, _, id, label)
				if not id and not label then
					wezterm.log_info("Cancelled")
				else
					wezterm.log_info("Selected " .. label)
					win:perform_action(
						act.SwitchToWorkspace({ name = id, spawn = { cwd = label } }),
						pane
					)
				end
			end),
			fuzzy = true,
			title = "Select project",
			choices = projects,
		},
		pane
	)
end

M.rename_session = function(window, pane)
	local old_name = window:active_workspace()
	window:perform_action(
		act.PromptInputLine {
			description = string.format("Enter new name for workspace '%s'", old_name),
			action = wezterm.action_callback(function(_, _, new_name)
				if not new_name then
					wezterm.log_error "did not provide a workspace name"
					return
				end
				wezterm.log_info(string.format("rename workspace from %s to %s", old_name, new_name))
				wezterm.mux.rename_workspace(old_name, new_name or old_name)
			end)
		},
		pane
	)
end

return M
