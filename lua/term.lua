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
		api.nvim_win_set_option(0, 'relativenumber', false)
		api.nvim_win_set_option(0, 'number', false)

		api.nvim_set_current_buf(current_buf)
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

return {
	toggle = toggle
}
