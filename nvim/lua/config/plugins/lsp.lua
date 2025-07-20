local AUGROUP_PREFIX = "__silver"
local LSP_AUGROUPS = {
	attach = AUGROUP_PREFIX .. ".lsp_attach",
	heightlight = AUGROUP_PREFIX .. ".lsp_highlight",
	detach = AUGROUP_PREFIX .. ".lsp_detach",
}


--- Install the following servers
local AUTO_INSTALL_SERVERS = {
	rust_analyzer = {},
	pyright = {},
	lua_ls = {},
}

--- LSP found in system
local SERVERS = {
	nushell = {},
}

-- CURSOR_HEIGHT = CURSOR_ASPECT_RATIO * CURSOR_WIDTH (I'm guessing)
local CURSOR_ASPECT_RATIO = 2

---@class Event
---@field id number autocommand id
---@field event string name of the triggered event |autocmd-events|
---@field group number|nil autocommand group id, if any
---@field match string expanded value of <amatch>
---@field buf number expanded value of <abuf>
---@field file string expanded value of <afile>
---@field data any arbitrary data passed from |nvim_exec_autocmds()|


---Register an auto-formatting event on saving the buffer.
---@param ev Event
---@param client vim.lsp.Client
local function register_format_on_save(ev, client)
	if not client.supports_method("textDocument/formatting") then
		return
	end
	local bufnr = ev.buf
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		callback = function()
			vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
		end,
	})
end

---Gets the current buffer `offset_encoding`, by iterating through all the
---attached LSP clients and getting the first recorded `offset_encoding`.
---@return string?
local function get_lsp_client_offset_encoding()
	local bufnr = vim.api.nvim_win_get_buf(0)

	local offset_encoding = nil
	for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		local encoding = client.offset_encoding
		if encoding ~= nil then
			offset_encoding = encoding
			break
		end
	end

	return offset_encoding
end

---Generate "Goto" keymaps combinations for the given `jumper` function. A given
---`jumper` will have the follwing mappings generated:
---
---1. `g<jump_key>`: just get their.
---2. `gV<jump_key>`: just get their in a **vertical** split.
---3. `gH<jump_key>`: just get their in a **horizontal** split.
---4. `gS<jump_key>`: just get their in a **split** (determines either vertically or
---   horizontally based on the window size).
---5. `gT<jump_key>`: just get their in a new **tab**.
---@param jumper function
---@param jump_key string
---@param mapper function
---@param mapping_description string
---@return nil
local function generate_jumpers(jumper, jump_key, mapper, mapping_description)
	local jump_types = {
		 { "", nil, "" },
		 { "V", "vsplit", " [V]ertically " },
		 { "H", "split", " [H]orizontally " },
		 { "T", "tab", " by [T]ab " },
	}

	for _, config in pairs(jump_types) do
		local key = config[1]
		local jump_type = config[2]
		local description = config[3]


		mapper(
			"g" .. key .. jump_key,
			function ()
				local offset_encoding = get_lsp_client_offset_encoding()
				local opts = {
					 jump_type = jump_type,
					 offset_encoding = offset_encoding,
				}
				jumper(opts)
			end,
			"[G]o" .. description .. "to " .. mapping_description
		)
	end

	mapper(
		"gS" .. jump_key,
		function ()
			local width = vim.api.nvim_win_get_width(0)
			local height = vim.api.nvim_win_get_height(0)

			local split_type = "vsplit"
			if (CURSOR_ASPECT_RATIO*height) >= width then
				split_type = "split"
			end
			local offset_encoding = get_lsp_client_offset_encoding()

			local opts = {
				 jump_type = split_type,
				 offset_encoding = offset_encoding,
			}

			jumper(opts)
		end,
		"[G]o by [S]plit to " .. mapping_description
	)
end

local function register_telescope_keymap(ev, client)
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
	end

	local telescope_builtin = require "telescope.builtin"
	local jump_list = {
		{ telescope_builtin.lsp_definitions, "d", "[D]efinition" },
		{ telescope_builtin.lsp_implementations, "I", "[I]mplementation" },
	}

	for _, jumps in pairs(jump_list) do
		local jumper, jump_key, desc   = jumps[1], jumps[2], jumps[3]
		generate_jumpers(jumper, jump_key, map, desc)
	end

	map(
		"gr",
		function()
			local offset_encoding = get_lsp_client_offset_encoding()
			local opts = {
				 offset_encoding = offset_encoding,
			}
			telescope_builtin.lsp_references(opts)
		end,
		"[G]oto [R]eferences"
	)

	map("<leader>D", telescope_builtin.lsp_type_definitions, "Type [D]efinition")
	map(
		"<leader>ds",
		function()
			local offset_encoding = get_lsp_client_offset_encoding()
			local opts = {
				 offset_encoding = offset_encoding,
			}
			telescope_builtin.lsp_document_symbols(opts)
		end,
		"[D]ocument [S]ymbols"
	)
	map("<leader>ws", telescope_builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
end

local function register_keymap(ev, client)
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
	end

	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

	if not client.server_capabilities.documentHighlightProvider then
		return
	end

	local highlight_augroup = vim.api.nvim_create_augroup(LSP_AUGROUPS.heightlight, { clear = false })

	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		buffer = ev.buf,
		group = highlight_augroup,
		callback = vim.lsp.buf.document_highlight,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = ev.buf,
		group = highlight_augroup,
		callback = vim.lsp.buf.clear_references,
	})
end

local function init(_, opts)
	local lspconfig = require "lspconfig"
	local blink = require "blink.cmp"

	for server, cfg in pairs(opts.servers) do
		cfg.capabilities = blink.get_lsp_capabilities(cfg.capabilities)
		lspconfig[server].setup(cfg)
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup(LSP_AUGROUPS.attach, { clear = true }),
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			register_format_on_save(ev, client)
			register_telescope_keymap(ev, client)
			register_keymap(ev, client)

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup(LSP_AUGROUPS.detach, { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds { group = LSP_AUGROUPS.heightlight, buffer = event2.buf }
				end,
			})
		end,
	})

	require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(AUTO_INSTALL_SERVERS) }
	require('mason-lspconfig').setup {
		handlers = {
			function(server_name)
				local cfg = AUTO_INSTALL_SERVERS[server_name] or {}
				cfg.capabilities = blink.get_lsp_capabilities(cfg.capabilities)
				lspconfig[server_name].setup(cfg)
			end,
		},
	}
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = SERVERS,
		},
		dependencies = {
			"saghen/blink.cmp",
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } }
				},
			},

			{ 'williamboman/mason.nvim', opts = {} },
			'williamboman/mason-lspconfig.nvim',
			'WhoIsSethDaniel/mason-tool-installer.nvim',
			{ 'j-hui/fidget.nvim',       opts = {} },
		},
		config = init,
	},
}
