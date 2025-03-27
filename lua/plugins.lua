-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/echasnovski/mini.nvim',
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd('packadd mini.nvim | helptags ALL')
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

local add, now = require('mini.deps').add, require('mini.deps').now

now(function()
	add({ name = 'mini.nvim', checkout = 'HEAD' })

	require('mini.pairs').setup()

	require('mini.completion').setup()
	vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
	vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
end)

if vim.fn.has('unix') == 1 then
	require('plugin/for_linux')
end

require('plugin/styles')

now(function()
	add({ source = 'mori-oh/nvimpc.lua' })
	local mpc = require('nvimpc')
	mpc.setup({
		host = os.getenv('MPD_HOST') or 'localhost',
		port = tonumber(os.getenv('MPD_PORT') or 6600),
	})
	vim.api.nvim_create_user_command('Mpc', function(opts)
		mpc.command(opts.args)
		print(table.concat(mpc.result, '\n'))
	end, { nargs = '?' })
end)
