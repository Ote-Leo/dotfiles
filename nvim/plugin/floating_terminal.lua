local M = {}

local state = {
	buffer = -1,
	window = -1,
}

---Create a floating window with a scratch buffer.
---@param opts? { width: integer, height: integer, buffer: integer }
---@return { buffer: integer , window: integer }
M.create_floating_window = function(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	if not vim.api.nvim_buf_is_valid(opts.buffer) then
		opts.buffer = vim.api.nvim_create_buf(false, true)
	end
	local buf = opts.buffer

	---@type vim.api.keyset.win_config
	local win_config = {
		row = row,
		col = col,
		width = width,
		height = height,
		relative = "editor",
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buffer = buf, window = win }
end

vim.api.nvim_create_user_command("FloatTerm", function(opts)
	if not vim.api.nvim_win_is_valid(state.window) then
		local floating_window = M.create_floating_window(state)
		state.window = floating_window.window
		if vim.bo[state.buffer].buftype ~= "terminal" then
			vim.cmd.terminal(opts.fargs[1] or "")
		end
	else
		vim.api.nvim_win_hide(state.window)
	end
end, { nargs = 1, })

return M
