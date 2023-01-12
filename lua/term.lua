local utils = {}

local termbuf = nil;
local api = vim.api;
local cmd = vim.cmd;

local function create_termbuf()
	if termbuf == nil or api.nvim_buf_is_valid(termbuf) == false then
		local current_buf = api.nvim_get_current_buf()
		termbuf = api.nvim_create_buf(false, false)
		api.nvim_set_current_buf(termbuf)
		vim.fn.termopen(vim.env.SHELL)

		api.nvim_buf_set_option(termbuf, 'buflisted', false)
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false

		api.nvim_set_current_buf(current_buf)

		vim.keymap.set('n', '<C-q>', '<cmd>tabclose<CR>', { buffer = termbuf })
	end
end

local function toggle()
	create_termbuf()

	if api.nvim_get_current_buf() == termbuf then
		cmd('tabclose')
	else
		cmd('tabnew')
		api.nvim_set_current_buf(termbuf)
		api.nvim_feedkeys('i', 'n', true)
	end
end

vim.api.nvim_create_autocmd({"TermClose"}, {
	callback = function(ev)
		if ev.status == nil and ev.buf ~= nil and ev.buf == termbuf and vim.api.nvim_buf_is_valid(ev.buf) and vim.api.nvim_buf_is_loaded(ev.buf) then
			vim.api.nvim_buf_delete(ev.buf, {});
		end
	end
})

return {
	toggle = toggle
}
