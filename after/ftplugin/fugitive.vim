if &modifiable
	finish
endif

nnoremap <buffer> gp :Git! push -u origin HEAD<CR>
nnoremap <buffer> ga :Git add --all<CR>
