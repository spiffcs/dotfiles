""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Maintainer:
"    Christopher Phillips - @spiffcs
"
" Sections:
"    -> Plugins
"    -> General
"    -> VIM UX
"    -> Colors and Fonts
"    -> Tabs, Windows and Buffers
"    -> Text, tab and indent related
"    -> Nerdtree
"    -> vim-ctrlspace
"    -> Coc.nvim
"    -> Golang
"    -> Rust
"    -> Ack searching and cope displaying
"
""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""
" Specify a director for plugins
" - For Neovim: ~/.vim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin()

" utility
Plug 'nvim-lua/plenary.nvim'

"ui
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ntpeters/vim-better-whitespace'

" code
Plug 'github/copilot.vim'
Plug 'neovim/nvim-lspconfig'

" file explorer
Plug 'nvim-telescope/telescope.nvim'
call plug#end()

lua << EOF
require'lspconfig'.gopls.setup{}
require'lspconfig'.rust_analyzer.setup{}
EOF
""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" Set line numbers in file
set number
set numberwidth=1

" turn hybrid line numbers on
set number relativenumber
set nu rnu

" With a mapleader it is possible to do extra key combinations
" EX: <leader>w saves the current file
let mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" set mouse support for normal and visual mode
set mouse=nv

""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM UX
""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the Wild menu
set wildmenu

" Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" Ignore case when searching, hilight results
set ignorecase
set smartcase
set hlsearch
set incsearch

" Don't redraw while executing macros (performance)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indivator is over them
set showmatch
set mat=2

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

set termguicolors
set background=dark
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

try
    colorscheme gruvbox
catch
endtry

" Airline Theme
let g:airline_theme='base16_gruvbox_dark_hard'

" Set utf8 as the standard encoding
set encoding=utf8

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Tabs, Windows and Buffers
""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search)
map <space> /

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Next and Previous buffer
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Smar tab moves
map <C-t>k :tabr<cr>
map <C-t>j :tabl<cr>
map <C-t>h :tabp<cr>
map <C-t>l :tabn<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
""""""""""""""""""""""""""""""""""""""""""""""""""
" Use tabs instead of spaces
set autoindent
set noexpandtab

" 1 tab == 4 spaces
set tabstop=4
set shiftwidth=4

" Linebreak on 500 char
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
""""""""""""""""""""""""""""""""""""""""""""""""""
" If hidden is not set, TextEdit might fail.
set hidden

" Turn backup off. We have git
set nobackup
set nowritebackup
set nowb
set noswapfile

set updatetime=100
set shortmess+=c
set signcolumn=yes

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""
" => nvim-lspconfig
""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
require('lspconfig')['pyright'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['rust_analyzer'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {}
    }
}
EOF
