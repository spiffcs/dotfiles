-- Maintainer:
--    Christopher Phillips - @spiffcs

-- Sections:
--    -> Plugins
--    -> General Settings
--    -> LSP and Completion
--    -> Filetype-Specific Settings
--    -> Keybindings
--    -> Lua Script Imports

-- -------------------------
-- Plugins
-- -------------------------

-- Set leader before lazy.nvim loads plugins
vim.g.mapleader = ","

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup({
	-- UI and Appearance
	{ "morhetz/gruvbox" },
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = { theme = "gruvbox" },
		},
	},
	{ "ntpeters/vim-better-whitespace" },
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
	{ "ellisonleao/glow.nvim", opts = {} },

	-- Completion and LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			-- Global LSP config: attach nvim-cmp capabilities to all servers
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			-- Lua Language Server
			vim.lsp.config("lua_ls", {
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
							return
						end
					end
					client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME },
						},
					})
				end,
				settings = {
					Lua = {},
				},
			})

			-- Go Language Server
			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
							shadow = true,
						},
						staticcheck = true,
					},
				},
			})

			-- Pyright Language Server
			vim.lsp.config("pyright", {
				settings = {
					pyright = {
						-- Using Ruff's import organizer
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							-- Ignore all files for analysis to exclusively use Ruff for linting
							ignore = { "*" },
						},
					},
				},
			})

			-- Enable all configured servers
			vim.lsp.enable({
				"lua_ls",
				"gopls",
				"rust_analyzer",
				"pyright",
				"ruff",
				"r_language_server",
				"ocamllsp",
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup()

			-- Ensure parsers are installed
			local wanted = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"r",
				"python",
				"go",
				"ocaml",
				"scala",
				"markdown",
				"markdown_inline",
				"rnoweb",
				"yaml",
				"csv",
			}
			local installed = require("nvim-treesitter.config").get_installed()
			local missing = vim.tbl_filter(function(lang)
				return not vim.list_contains(installed, lang)
			end, wanted)
			if #missing > 0 then
				require("nvim-treesitter.install").install(missing, { summary = true })
			end

			-- Enable treesitter-based highlighting and indentation
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
				callback = function(ev)
					if pcall(vim.treesitter.start, ev.buf) then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},

	-- Formatting and Linting
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofmt", "goimports" },
				python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
				ocaml = { "ocamlformat" },
				r = { "styler" },
				rust = { "rustfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				lua = { "luacheck" },
			}

			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
				group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	-- Debugger
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"leoluz/nvim-dap-go",
		},
		config = function()
			require("dap-config")
		end,
	},

	-- Language-specific
	{ "R-nvim/R.nvim", version = "~0.99.0" },
	{
		"scalameta/nvim-metals",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "scala", "sbt" },
		config = function()
			local metals = require("metals")
			local metals_config = metals.bare_config()
			metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Ensure JAVA_HOME is set so the metals launcher can find java
			if not vim.env.JAVA_HOME or vim.env.JAVA_HOME == "" then
				local result = vim.fn.system("cs java-home --jvm 21 2>/dev/null")
				if vim.v.shell_error == 0 then
					vim.env.JAVA_HOME = vim.trim(result)
				end
			end

			metals_config.settings = {
				showImplicitArguments = true,
				javaHome = vim.env.JAVA_HOME,
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "scala", "sbt" },
				group = vim.api.nvim_create_augroup("nvim_metals", { clear = true }),
				callback = function()
					metals.initialize_or_attach(metals_config)
				end,
			})
		end,
	},
	{ "rhysd/committia.vim" },

	-- Code Navigation and Comments
	{ "junegunn/fzf.vim", dependencies = { "junegunn/fzf" } },
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
})

-- -------------------------
-- General Settings
-- -------------------------

vim.o.history = 500
vim.o.number = true
vim.o.numberwidth = 1
vim.o.relativenumber = true
vim.o.mouse = "nv"

-- VIM UX
vim.o.scrolloff = 7
vim.o.ruler = true
vim.o.cmdheight = 1
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.lazyredraw = true
vim.o.showmatch = true
vim.o.matchtime = 2

-- Misc
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.updatetime = 100
vim.opt.shortmess:append("c")
vim.o.signcolumn = "yes"

-- Colors and Fonts
vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")

-- -------------------------
-- LSP and Completion
-- -------------------------

-- Diagnostic settings
vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		focusable = false,
		source = true,
		max_width = 80,
		max_height = 20,
	},
})

-- Open diagnostics on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float({ focusable = false })
	end,
})

-- Apply wrapping for LSP hover and diagnostic messages
vim.api.nvim_create_autocmd("FileType", {
	pattern = "lspinfo,lsp-hover",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

-- Disable ruff hover so Pyright provides type-aware hover instead
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then
			return
		end
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end
	end,
	desc = "LSP: Disable hover capability from Ruff",
})

-- Keybinding for diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { silent = true, desc = "Show diagnostic float" })

-- -------------------------
-- Filetype-Specific Settings
-- -------------------------

local function set_indentation(pattern, tabsize, use_spaces)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = pattern,
		callback = function()
			vim.bo.tabstop = tabsize
			vim.bo.shiftwidth = tabsize
			vim.bo.expandtab = use_spaces
		end,
	})
end

set_indentation("lua", 2, true)
set_indentation("python", 4, true)
set_indentation("make", 4, false)
set_indentation("go", 4, false)
set_indentation("html", 2, true)
set_indentation("javascript", 2, true)
set_indentation("r", 2, true)
set_indentation("scala", 2, true)

-- -------------------------
-- Keybindings
-- -------------------------

-- General
vim.keymap.set("n", "<leader>w", ":w!<CR>", { silent = true, desc = "Quick save" })
vim.keymap.set("n", "<leader>r", ":FZF<CR>", { silent = true, desc = "Fuzzy find files" })

-- nvim-tree
vim.keymap.set("n", "<leader>n", ":NvimTreeFocus<CR>", { silent = true, desc = "Focus file tree" })
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle file tree" })
vim.keymap.set("n", "<C-f>", ":NvimTreeFindFile<CR>", { silent = true, desc = "Find file in tree" })

-- LSP (K, grr, gri, grn, gra are provided by nvim 0.11 defaults)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "Go to definition" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })

-- File search with ripgrep
vim.keymap.set("n", "<leader>fw", ":Rg<CR>", { silent = true, desc = "Ripgrep search" })

-- Tabs, Windows and Buffers
vim.keymap.set("n", "<Space>", "/", { remap = true, desc = "Search" })
vim.keymap.set("n", "<C-j>", "<C-W>j", { silent = true, desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-W>k", { silent = true, desc = "Window up" })
vim.keymap.set("n", "<C-h>", "<C-W>h", { silent = true, desc = "Window left" })
vim.keymap.set("n", "<C-l>", "<C-W>l", { silent = true, desc = "Window right" })
vim.keymap.set("n", "<leader>=", "<C-w>=", { silent = true, desc = "Equalize windows" })
vim.keymap.set("n", "<leader>l", ":bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>h", ":bprevious<CR>", { silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<C-t>k", ":tabr<CR>", { silent = true, desc = "First tab" })
vim.keymap.set("n", "<C-t>j", ":tabl<CR>", { silent = true, desc = "Last tab" })
vim.keymap.set("n", "<C-t>h", ":tabp<CR>", { silent = true, desc = "Previous tab" })
vim.keymap.set("n", "<C-t>l", ":tabn<CR>", { silent = true, desc = "Next tab" })
vim.keymap.set("n", "<leader><CR>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
