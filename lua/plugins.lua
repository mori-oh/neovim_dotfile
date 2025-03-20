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
add({ name = 'mini.nvim', checkout = 'HEAD' })

require('mini.pairs').setup()

add({ source = 'akinsho/toggleterm.nvim' })
now(function()
	require('toggleterm').setup({
		hide_numbers = true,
		direction = 'float',
		start_in_insert = true,
		insert_mappings = true,
	})
end)

if vim.fn.has('unix') == 1 then
	require('plugin/for_linux')
end

require('plugin/styles')

local function parseNowPlaying(array)
	local t = {}
	for _,s in pairs(array) do
		for k, v in string.gmatch(s, "(.+): (.+)") do
			t[k] = v
		end
	end
	return t
end

local function parseQueue(array,key)
	local t = {}
	local i = 1
	for _,s in pairs(array) do
		for v in string.gmatch(s,key .. ": (.+)") do
			t[i] = v
			i = i + 1
		end
	end
	return t
end

local function dispTbl(tbl)
	for key, val in pairs(tbl) do
		print(key ,':', val)
	end
end

add({ source = 'mori-oh/nvimpc.lua' })
now(function()
	local mpc = require('nvimpc')
	mpc.setup({
		host = os.getenv('MPD_HOST') or 'localhost',
		port = tonumber(os.getenv('MPD_PORT') or 6600),
	})
	vim.api.nvim_create_user_command('Mpc', function(opts)
		mpc.command(opts.args)
		print(table.concat(mpc.result, '\n'))
	end, { nargs = '?' })

	vim.api.nvim_create_user_command('MpcNowPlaying', function()
		mpc.command('currentsong')
		local tbl = parseNowPlaying(mpc.result)
		print(tbl.Title,'/',tbl.Artist , '-', tbl.Album)
	end, { })
	vim.api.nvim_create_user_command('MpcQueue', function()
		mpc.command('playlistinfo')
		local tbl = parseQueue(mpc.result,'Title')
		dispTbl(tbl)
	end, { })
end)
