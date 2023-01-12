local g = vim.g
local opt = vim.opt

-- Long lines are on same indent level
opt.breakindent = true

-- Mouse
opt.mouse = 'a'
opt.mousehide = true
opt.mousemodel = 'popup'

-- Enable history
opt.history = 1000
-- Enable hidden buffers
opt.hidden = true
-- Don't redraw while executing macro
opt.lazyredraw = true

-- Disable bell
opt.errorbells = false
opt.visualbell = false

-- Auto jump to first error
opt.cf = true

-- Enable : in keywords
opt.iskeyword = '@,~,48-57,_,192-255'

-- Set grep prorgram
opt.grepprg = 'grep -nH $*'

-- Set visible lines / columns before and after cursor
opt.scrolloff = 3
opt.sidescroll = 5

-- Integrate clipboard
opt.clipboard = 'unnamed,unnamedplus'
--
-- Menu inside command line
opt.wildmenu = true

--
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- => Saving
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
--
-- Backup
opt.backup = true
opt.backupdir = vim.fn.stdpath("data") .. "/backup//"

--
-- Tmp directory
opt.directory = vim.fn.stdpath("data") .. "/swap//"
--
-- Ask before close
opt.confirm = true
--
-- Viminfo
-- set viminfo='50,\"500
--              |    |
--              |    + Maximum number of files for each register
--              + Save max 50 files
--
-- Persistent undo
opt.undodir = vim.fn.stdpath("data") .. "/undo//"
opt.undofile = true
opt.undolevels = 2048
opt.undoreload = 65538

--
opt.completeopt = 'menuone,menu'
--                 |       |
--                 |       + Display popup
--                 + Display when single option


-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Display
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
opt.textwidth = 80
opt.colorcolumn = '80'
opt.wrap = true

-- Enable line number display
opt.number = true
opt.relativenumber = true
--
-- Hide conceal chars
opt.conceallevel = 2

-- Show title in terminal window
opt.title = true
--
-- Show matching brackets
opt.showmatch = true
--
-- Highlidhgt search
opt.hlsearch = true
opt.incsearch = true

-- Disable toolbars
-- if has("gui_running")
-- 	set guioptions-=T
-- endif
--
-- Enable syntax
opt.syntax = 'on'

-- Whitespace symbols
if vim.fn.has('multi_byte') then
	opt.fillchars = 'stl: ,stlnc: ,vert:┃,fold:-,diff:-'
--	"set lcs=tab:\⁝\ ,trail:•,extends:>,precedes:<,nbsp:¤"
	opt.lcs = 'tab:┆ ,extends:>,precedes:<,trail:•,nbsp:¤'
	opt.sbr = '…'
	--let &sbr = nr2char(8618).' '
else
	opt.fillchars = 'stl: ,stlnc: ,vert:|,fold:-,diff:-'
	opt.lcs = 'tab:> ,extends:>,precedes:<,trail:-'
	opt.sbr = '+++'
end

opt.list = true

vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "WinEnter", "CmdwinEnter"}, {
	callback = function()
		if (vim.wo.previewwindow or vim.fn.bufname() == "__BUFFERLIST__") then
			vim.opt_local.list = false
		end
	end
})


-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- => Formating
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- Prevent auto indenting while typing

opt.formatoptions = 'croq1'
--                   |||||
--                   ||||+ Not break lines in insert mode
--                   |||+ Formatting with gq
--                   ||+ Insert comment leader after 'o'
--                   |+ Insert comment leader after <Enter>
--                   + Auto wrap comments using textwidth
--
-- Wrap on end
opt.wrapmargin = 0
opt.linebreak = true
--
-- Copy indent structure
opt.copyindent = true
opt.preserveindent = true
--
-- Round to tabs
opt.shiftround = true
--
-- Use tabs
opt.tabstop = 3
opt.shiftwidth = 3
--
-- Indent for language
opt.smartindent = true

opt.cmdheight = 0

g.c_no_curly_error = 1

vim.cmd('colorscheme mirec')
