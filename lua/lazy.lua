local lazy_cleanup = function(opts)
	if opts['map'] ~= nil then
		for _, mapping in ipairs(opts['map']) do
			vim.keymap.del('', mapping, {})
		end
	end
	if opts['event'] ~= nil then
		for _, event in ipairs(opts['event']) do
			vim.api.nvim_del_autocmd(event._auto_id)
		end
	end
end

local run_hook = function(opts, name)
	local hook = opts[name];
	if hook ~= nil then
		if type(hook) == "string" then
			vim.api.nvim_exec(hook)
		else
			hook()
		end
	end
end

local load_plugin = function(opts)
	lazy_cleanup(opts)
	run_hook(opts, 'pre')
	for _, plugin in ipairs(opts['plugins']) do
		vim.api.nvim_command('packadd ' .. plugin)
	end
	run_hook(opts, 'post')
end

local key_event = function(key, opts)
	return function()
		load_plugin(opts)
		vim.api.nvim_input(key)
	end
end

local auto_event = function(opts)
	return function()
		load_plugin(opts)
	end
end


local lazy = function(opts)
	if opts['map'] ~= nil then
		for _, mapping in ipairs(opts['map']) do
			vim.keymap.set('', mapping, key_event(mapping, opts), {})
		end
	end
	if opts['event'] ~= nil then
		for _, event in ipairs(opts['event']) do
			local event_opts = event.opts;
			if event_opts == nil then
				event_opts = {}
			else
				event_opts = {}
				for key, val in pairs(event.opts) do
					event_opts[key] = val
				end
			end
			event_opts.callback = auto_event(opts)
			local id = vim.api.nvim_create_autocmd(event.names, event_opts)
			event._auto_id = id
		end
	end
end


return lazy
