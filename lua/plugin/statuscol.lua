local STATUSCOL = {}

local function signs(ns, add_sign)
	local sign = { namespace = { ns }, maxwidth = 1, colwidth = 1, auto = false }
	for k, v in pairs(add_sign) do sign[k] = v end
	return { sign = sign, click = 'v:lua.ScSa' }
end

function STATUSCOL.setup()
	local builtin = require('statuscol.builtin')
	local ignore = { 'terminal', 'nofile', 'help' }
	local diag = signs('diagnostic', { serverity_sort = true })
	local dap = signs('Dap', {})
	local lnum = { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' }
	local fold = { text = { builtin.foldfunc }, click = 'v:lua.ScFa' }
	local git = signs('git', { wrap = true, fillchar = '│', fillcharhl = 'NonText' })

	require('statuscol').setup({ bt_ignore = ignore, segments = { diag, dap, lnum, fold, git } })
end

return STATUSCOL
