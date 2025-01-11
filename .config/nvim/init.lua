-- Maintainer:
--    Christopher Phillips - @spiffcs

-- Sections:
--    -> Plugins
--    -> General Settings
--    -> LSP and Completion
--    -> Formatting, Linting, and Treesitter
--    -> Filetype-Specific Settings
--    -> Keybindings
--    -> UI and Appearance

-- -------------------------
-- Plugins
-- -------------------------

-- Ensure packer is installed
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({
			"git",
			"clone",
			"--depth",
			"1",
			"https://github.com/wbthomason/packer.nvim",
			install_path,
		})
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

-- Packages to install
local packer_bootstrap = ensure_packer()
require("packer").startup(function(use)
	-- Plugin management
	use("wbthomason/packer.nvim") -- Packer can manage itself

	-- UI and Appearance
	use("morhetz/gruvbox")
	use("vim-airline/vim-airline")
	use("vim-airline/vim-airline-themes")
	use("ntpeters/vim-better-whitespace")
	use("preservim/nerdtree")

	-- Completion and LSP
	use("neovim/nvim-lspconfig")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	-- Formatting and Linting
	use("mhartington/formatter.nvim")
	use("mfussenegger/nvim-lint")

	-- Language-specific
	use({ "fatih/vim-go", run = ":GoUpdateBinaries" }) -- Go
	use({ "R-nvim/R.nvim", lazy = false, version = "~0.1.0" }) -- R
	use("rhysd/committia.vim") -- git commit highlighter

	-- Code Navigation and Comments
	use("junegunn/fzf")
	use({ -- Comment Support
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})
	use("github/copilot.vim") -- Copilot

	if packer_bootstrap then
		require("packer").sync()
	end
end)

-- -------------------------
-- General Settings
-- -------------------------

-- General
vim.g.mapleader = ","
vim.o.history = 500
vim.o.autoread = true
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
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.lazyredraw = true
vim.o.magic = true
vim.o.showmatch = true
vim.o.matchtime = 2

-- Misc
vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.updatetime = 100
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.signcolumn = "yes"

-- Colors and Fonts
vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
vim.g.airline_theme = "base16_gruvbox_dark_hard"
vim.o.encoding = "utf-8"

-- -------------------------
-- LSP and Completion
-- -------------------------

-- Setup nvim-cmp for LSP completion
local cmp = require("cmp")
cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" }, -- Buffer completion source
		{ name = "path" }, -- Path completion source
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		-- Bind Tab to cycle forward through completions
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item() -- Select next completion item
			else
				fallback() -- Fallback to default Tab behavior (e.g., indentation)
			end
		end, { "i", "s" }),
		-- Bind Shift-Tab to cycle backward through completions
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item() -- Select previous completion item
			else
				fallback() -- Fallback to default Shift-Tab behavior (e.g., previous item in insert mode)
			end
		end, { "i", "s" }),
	}),
})

-- Diagnostic settings
vim.diagnostic.config({
	virtual_text = false, -- Disable inline virtual text (optional, reduces clutter)
	signs = true, -- Show signs in the gutter
	underline = true, -- Underline the problematic code
	update_in_insert = false, -- Update diagnostics only in normal mode
	severity_sort = true, -- Sort diagnostics by severity
	float = {
		border = "rounded", -- Rounded border for better aesthetics
		focusable = false, -- Prevent focusing the diagnostic window
		source = true, -- Show the diagnostic source (e.g., "lua-language-server")
		max_width = 80, -- Limit the width of the diagnostic float
		max_height = 20, -- Limit the height of the diagnostic float
	},
})

-- Open diagnostics on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false })
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

-- Keybindings for diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true }) -- Previous diagnostic
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true }) -- Next diagnostic

-- -------------------------
-- Language Server Setup
-- -------------------------

-- Attach `nvim-cmp` to LSP
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

-- Lua Language Server
lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT", -- Lua version used
				path = vim.split(package.path, ";"),
			},
			diagnostics = {
				globals = { "vim" }, -- Recognize `vim` global
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true), -- Neovim runtime files
			},
			telemetry = {
				enable = false, -- Disable telemetry
			},
		},
	},
})

-- Go Language Server
lspconfig.gopls.setup({
	cmd = { "gopls" },
	capabilities = capabilities,
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
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

-- R Language Server
lspconfig.r_language_server.setup({
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd", "R" },
	root_dir = lspconfig.util.root_pattern(".git", "."),
	capabilities = capabilities,
})

-- Ocaml Language Server
lspconfig.ocamllsp.setup({
	cmd = { "ocamllsp" }, -- Ensure the ocaml-lsp-server binary is in your PATH
	capabilities = capabilities,
	filetypes = { "ocaml", "ocamlinterface", "ocamllex" },
	root_dir = lspconfig.util.root_pattern("*.opam", ".git", "dune-project", "dune-workspace"),
	settings = {},
})

-- -------------------------
-- Formatting, Linting, and Treesitter
-- -------------------------

-- Linting
require("lint").linters_by_ft = {
	lua = { "luacheck" }, -- Use luacheck for linting Lua files
}

-- Treesitter setup
require("nvim-treesitter.configs").setup({
	syntax = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	sync_install = true,
	auto_install = true,
	-- Add Languages for Treesitter
	ensure_installed = {
		"r",
		"go",
		"ocaml",
		"lua",
		"markdown",
		"markdown_inline",
		"rnoweb",
		"yaml",
		"csv",
	},
	highlight = {
		enable = true, -- Enable syntax highlighting
	},
	indent = {
		enable = true,
	},
})

-- Formatter setup
require("formatter").setup({
	filetype = {
		lua = {
			-- "formatter.filetypes.lua" defines default "lua" filetype
			require("formatter.filetypes.lua").stylua,
		},
		-- Opt-in to default formatter for R files
		r = require("formatter.filetypes.r").styler,
		-- TODO: incorporate python, ocaml, etc
		-- Go, Rust toolchains already do this
	},
})

-- Auto group for format on write
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})

-- Go Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Ocaml Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.ml,*.mli",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Lua Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.lua",
	command = "FormatWrite",
})

-- -------------------------
-- Filetype-Specific Setting
-- -------------------------

-- Create an autocommand group for clean configuration
vim.cmd([[
  augroup FileTypeSpecific
    autocmd!
  augroup END
]])

-- Helper function to set tab/spaces configuration
local function set_indentation(ft, tabsize, use_spaces)
	local expandtab = use_spaces and "setlocal expandtab" or "setlocal noexpandtab"
	vim.cmd(string.format(
		[[
    autocmd FileType %s setlocal tabstop=%d shiftwidth=%d | %s
  ]],
		ft,
		tabsize,
		tabsize,
		expandtab
	))
end

-- Filetype-specific configurations
set_indentation("lua", 2, true) -- Lua: 2 spaces, uses spaces
set_indentation("python", 4, true) -- Python: 4 spaces, uses spaces
set_indentation("make", 4, false) -- Makefiles: 4 spaces, uses tabs
set_indentation("go", 4, false) -- Go: 4 spaces, uses tabs
set_indentation("html", 2, true) -- HTML: 2 spaces, uses spaces
set_indentation("javascript", 2, true) -- JavaScript: 2 spaces, uses spaces
set_indentation("r", 2, true) -- R: 2 spaces, uses spaces

-- -------------------------
-- Keybindings
-- -------------------------

-- General key mappings
local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap("n", "<leader>w", ":w!<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>r", ":FZF<CR>", opts)

-- NerdTree key mappings
vim.api.nvim_set_keymap("n", "<leader>n", ":NERDTreeFocus<CR>", opts)
vim.api.nvim_set_keymap("n", "<C-n>", ":NERDTreeToggle<CR>", opts)
vim.api.nvim_set_keymap("n", "<C-f>", ":NERDTreeFind<CR>", opts)

-- Copilot configuration
vim.g.copilot_no_tab_map = true -- Disable default Tab mapping for Copilot
-- Keymap for triggering Copilot completion
vim.api.nvim_set_keymap("i", "<leader>c", "copilot#Next()", { noremap = true, silent = true, expr = true })
-- To accept Copilot suggestions, we can use the Enter key, or you can map it to something else
vim.api.nvim_set_keymap("i", "<leader>a", "copilot#Accept()", { noremap = true, silent = true, expr = true })

-- LSP goto, docs, references, rename
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

-- Tabs, Windows and Buffers
vim.api.nvim_set_keymap("n", "<Space>", "/", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-W>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-W>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-W>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-W>l", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>l", ":bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>h", ":bprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-t>k", ":tabr<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-t>j", ":tabl<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-t>h", ":tabp<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-t>l", ":tabn<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader><CR>", ":nohlsearch<CR>", { noremap = true, silent = true })
