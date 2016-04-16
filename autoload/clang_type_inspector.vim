let s:save_cpo = &cpo
set cpo&vim

let g:clang_type_inspector#canonical_type = get(g:, 'clang_type_inspector#canonical_type', 0)
let g:clang_type_inspector#automatic_inspection = get(g:, 'clang_type_inspector#automatic_inspection', 1)
let g:clang_type_inspector#disable_balloon = get(g:, 'clang_type_inspector#disable_balloon', 0)
let g:clang_type_inspector#default_compiler_args = get(g:, 'clang_type_inspector#default_compiler_args', '-std=c++1y')
let g:clang_type_inspector#shorten_too_long_type_name = get(g:, 'g:clang_type_inspector#shorten_too_long_type_name', 1)

let s:prev_pos = []

function! s:prepare_temp_file(bufnr)
    let temp_name = tempname() . (&filetype==#'c' ? '.c' : '.cpp')
    if -1 == writefile(getbufline(a:bufnr, 1, '$'), temp_name)
        throw "Could not create a temporary file : ".temp_name
    endif
    return temp_name
endfunction

function! clang_type_inspector#inspect_type_at(line, col, option)
    let compiler_args = has_key(a:option, 'compiler_args') ?
                            \ a:option.compiler_args :
                            \ get(b:, 'clang_type_inspector_default_compiler_args', g:clang_type_inspector#default_compiler_args)
    if has_key(a:option, 'file')
        let type_info = libclang#deduction#type_at(a:option.file, a:line, a:col, compiler_args)
    else
        let bufnr = has_key(a:option, 'bufnr') ? a:option.bufnr : bufnr('%')
        let file_name = s:prepare_temp_file(bufnr)
        try
            let type_info = libclang#deduction#type_at(file_name, a:line, a:col, compiler_args)
        finally
            call delete(file_name)
        endtry
    endif

    if empty(type_info) || ! has_key(type_info, 'type')
        return ""
    endif

    if g:clang_type_inspector#canonical_type == 2 || type_info.type ==# type_info.canonical.type
        return type_info.canonical.type
    elseif g:clang_type_inspector#canonical_type == 1
        return printf('%s ( %s )', type_info.canonical.type, type_info.type)
    else
        return type_info.type
    endif
    return ''
endfunction

function! s:shorten_for_oneline_output(output)
    return a:output[:(&columns - 1) - 3] . '...'
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

    let name = clang_type_inspector#inspect_type_at(line('.'), col('.'), {})

    if g:clang_type_inspector#shorten_too_long_type_name && len(name) > &columns
        let name = s:shorten_for_oneline_output(name)
    endif

    echo name
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
    let name = clang_type_inspector#inspect_type_at(v:beval_lnum, v:beval_col, {'bufnr' : v:beval_bufnr})

    if g:clang_type_inspector#shorten_too_long_type_name && len(name) > &columns
        let name = s:shorten_for_oneline_output(name)
    endif
    return name
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
