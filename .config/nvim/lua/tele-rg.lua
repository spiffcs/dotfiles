local telescope = require("telescope")
local actions = require("telescope.actions")

-- Configure Telescope
telescope.setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		prompt_prefix = "🔍 ",
		selection_caret = "➤ ",
		path_display = { "truncate" },
		mappings = {
			i = {
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,
			},
		},
	},
	pickers = {
		find_files = {
			theme = "dropdown",
		},
	},
	extensions = {},
})
