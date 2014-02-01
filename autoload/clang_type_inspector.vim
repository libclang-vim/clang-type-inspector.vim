let g:clang_type_inspector#canonical_type = get(g:, 'clang_type_inspector#non_canonical_type', 1)
let g:clang_type_inspector#automatic_inspection = get(g:, 'clang_type_inspector#automatic_inspection', 1)
let g:clang_type_inspector#disable_balloon = get(g:, 'clang_type_inspector#disable_balloon', 0)

let s:prev_pos = []

function! s:prepare_temp_file(bufnr)
    let temp_name = tempname() . (&filetype==#'c' ? '.c' : '.cpp')
    if -1 == writefile(getbufline(a:bufnr, 1, '$'), temp_name)
        throw "Could not create a temporary file : ".temp_name
    endif
    return temp_name
endfunction

function! clang_type_inspector#inspect_type_at(line, col, option)
    if has_key(a:option, 'file')
        let type_info = libclang#deduction#type_at(a:option.file, a:line, a:col)
    else
        let bufnr = has_key(a:option, 'bufnr') ? a:option.bufnr : bufnr('%')
        let file_name = s:prepare_temp_file(bufnr)
        try
            let type_info = libclang#deduction#type_at(file_name, a:line, a:col)
        finally
            call delete(file_name)
        endtry
    endif

    if empty(type_info)
        return ""
    endif

    if ! g:clang_type_inspector#canonical_type
        return type_info.type
    else
        return type_info.canonical.type
    endif
endfunction

function! clang_type_inspector#inspect_type_if_auto()
    if expand('<cword>') !=# 'auto'
        let s:prev_pos = []
        return
    endif

    let pos = getpos('.')
    let c = getline('.')[col('.')-1]
    if c ==# 'o'
        let pos[2] -= 3
    elseif c ==# 't'
        let pos[2] -= 2
    elseif c ==# 'u'
        let pos[2] -= 1
    endif

    if pos == s:prev_pos
        return
    endif
    let s:prev_pos = pos

    echo clang_type_inspector#inspect_type_at(line('.'), col('.'), {})
endfunction

function! clang_type_inspector#toggle_balloon()
    if &l:balloonexpr ==# ''
        " if not active
        setlocal balloonexpr=clang_type_inspector#balloon_expr()
    else
        " if active
        setlocal balloonexpr=
    endif
endfunction

function! clang_type_inspector#balloon_expr()
    return clang_type_inspector#inspect_type_at(v:beval_lnum, v:beval_col, {'bufnr' : v:beval_bufnr})
endfunction
