return {
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		init = function()
			local todo_comments = require "todo-comments"

			todo_comments.setup {}
			vim.keymap.set("n", "]t", todo_comments.jump_next, { desc = "Next TODO comment" })
			vim.keymap.set("n", "[t", todo_comments.jump_prev, { desc = "Previous TODO comment" })

			vim.keymap.set(
				"n",
				"]T",
				function()
					todo_comments.jump_next { keywords = { "ERROR", "WARNING" } }
				end,
				{ desc = "Next error/warning TODO comment" }
			)

			vim.keymap.set(
				"n",
				"[T",
				function()
					todo_comments.jump_prev { keywords = { "ERROR", "WARNING" } }
				end,
				{ desc = "Previous error/warning TODO comment" }
			)
		end,
	},
}
