-- Maintainer:
--    Christopher Phillips - @spiffcs

-- Sections:
--    -> Plugins
--    -> General
--    -> VIM UX
--    -> Colors and Fonts
--    -> Tabs, Windows and Buffers
--    -> Text, tab and indent related
--    -> Misc
--    -> Telescope

-- Plugins
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
    -- Plugin management
    use 'wbthomason/packer.nvim' -- Packer can manage itself

    -- UI
    use 'morhetz/gruvbox'
    use 'vim-airline/vim-airline'
    use 'vim-airline/vim-airline-themes'
    use 'ntpeters/vim-better-whitespace'
    use 'preservim/nerdtree'

	-- Completion
	use 'neovim/nvim-lspconfig'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-cmdline'
	use 'hrsh7th/nvim-cmp'

    -- Code
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'fatih/vim-go', run = ':GoUpdateBinaries' }
    use 'github/copilot.vim'

    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- Completion
local cmp = require('cmp')
cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
})

-- LSP Configuration
local lspconfig = require('lspconfig')

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

-- R Language Server setup
lspconfig.r_language_server.setup{
    cmd = { "R", "--slave", "-e", "languageserver::run()" },
    filetypes = { "r", "rmd" },
    root_dir = lspconfig.util.root_pattern(".git", "."),
}

-- Go Language Server setup
lspconfig.gopls.setup{
    cmd = { "gopls" },
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
}

-- Go Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        vim.lsp.buf.format()
    end,
})

require('nvim-treesitter.configs').setup {
    ensure_installed = { "r", "go"}, -- Add R for Treesitter
    highlight = {
        enable = true, -- Enable syntax highlighting
    },
	indent = {
		enable = true,
	},
}

-- General
vim.o.history = 500
vim.o.autoread = true
vim.o.number = true
vim.o.numberwidth = 1
vim.o.relativenumber = true
vim.g.mapleader = ","
vim.api.nvim_set_keymap('n', '<leader>w', ':w!<CR>', { noremap = true, silent = true })
vim.o.mouse = 'nv'

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

-- Nerdtree
vim.api.nvim_set_keymap('n', '<leader>n', ':NERDTreeFocus<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', ':NERDTreeFind<CR>', { noremap = true, silent = true })

-- Colors and Fonts
vim.o.termguicolors = true
vim.o.background = 'dark'
pcall(vim.cmd, 'colorscheme gruvbox')
vim.g.airline_theme = 'base16_gruvbox_dark_hard'
vim.o.encoding = 'utf-8'

-- Tabs, Windows and Buffers
vim.api.nvim_set_keymap('n', '<Space>', '/', { noremap = false })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-W>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-W>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<C-W>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-W>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>l', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', ':bprevious<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>k', ':tabr<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>j', ':tabl<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>h', ':tabp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>l', ':tabn<CR>', { noremap = true, silent = true })

-- Text, Tab and Indent Related
vim.o.autoindent = true
vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.linebreak = true
vim.o.textwidth = 500
vim.o.smartindent = true
vim.o.wrap = true

-- Misc
vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.updatetime = 100
vim.o.shortmess = vim.o.shortmess .. 'c'
vim.o.signcolumn = 'yes'
