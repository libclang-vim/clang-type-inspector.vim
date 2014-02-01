if exists('g:loaded_clang_type_inspector')
    finish
endif

noremap <silent><Plug>(clang-inspect-type-at-cursor) :<C-u>echo clang_type_inspector#inspect_type_at(line('.'), col('.'), {})<CR>
augroup plugin-clang-type-inspector-auto
    autocmd!
augroup END

let g:loaded_clang_type_inspector = 1
