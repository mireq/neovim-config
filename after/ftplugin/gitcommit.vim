function! s:insertTime()
	let s:tt=system("git timetrack -c")
	let s:issue=system("git timetrack --issue|tr \"\\n\" \" \"")
	let s:hours=system("grep hours||echo -ne ' 0 hours'", s:tt)
	let s:minutes=system("grep minutes||echo -ne ' 0 minutes'", s:tt)
	let s:hours=system("tr \"\\n\" \" \"|sed -e 's/.* \\(\\([0-9]\\+\\) hours\\).*/\\2/g'", s:hours)
	let s:minutes=system("tr \"\\n\" \" \"|sed -e 's/.* \\(\\([0-9]\\+\\) minutes\\).*/\\2/g'", s:minutes)
	"let s:minutes=system("sed -e 's/^[0-9]$/0\\0/g'", s:minutes)
	let s:reg = @a
	let @a= s:issue
	execute "normal! \"ap"
	if s:tt == "There's no time information :(\n"
		return
	endif
	let @a= ' @' . printf("%d", s:hours) . ":" . printf("%02d", s:minutes)
	execute "normal! \"ap"
	let @a=s:reg
endfunction

nnoremap <buffer> <C-t> :call <SID>insertTime()<CR>
inoremap <buffer> <C-t> <ESC>:call <SID>insertTime()<CR>i

nnoremap <buffer> <C-r> arefs <ESC>:call <SID>insertTime()<CR>
inoremap <buffer> <C-r> refs <ESC>:call <SID>insertTime()<CR>i

nnoremap <buffer> <C-c> acloses <ESC>:call <SID>insertTime()<CR>
inoremap <buffer> <C-c> closes <ESC>:call <SID>insertTime()<CR>i

nnoremap <buffer> <C-e> aresolves <ESC>:call <SID>insertTime()<CR>
inoremap <buffer> <C-e> resolves <ESC>:call <SID>insertTime()<CR>i

inoreabbrev <buffer> BB BREAKING CHANGE:
nnoremap <buffer> i i<C-r>=<sid>commit_type()<CR>

fun! s:commit_type()
	if col('.') == 1 && line('.') == 1
		call complete(1, ['build: ', 'bump: ', 'ci: ', 'docs: ', 'feat: ', 'fix: ', 'perf: ', 'refactor: ', 'revert: ', 'style: ', 'test: '])
	endif
	return ''
endfun
