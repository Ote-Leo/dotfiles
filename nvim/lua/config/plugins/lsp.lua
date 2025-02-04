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
}

--- LSP found in system
local SERVERS = {
	lua_ls = {},
	nushell = {},
}

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

local function register_telescope_keymap(ev, client)
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
	end

	local telescope_builtin = require "telescope.builtin"
	map("gd", telescope_builtin.lsp_definitions, "[G]oto [D]efinition")
	map("gr", telescope_builtin.lsp_references, "[G]oto [R]eferences")
	map("gI", telescope_builtin.lsp_implementations, "[G]oto [I]mplementation")
	map("<leader>D", telescope_builtin.lsp_type_definitions, "Type [D]efinition")
	map("<leader>ds", telescope_builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
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
