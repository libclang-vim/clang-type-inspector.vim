if g:clang_type_inspector#automatic_inspection
    autocmd plugin-clang-type-inspector-auto CursorMoved <buffer> call clang_type_inspector#inspect_type_if_auto()
endif

if ! g:clang_type_inspector#disable_balloon && has('gui_running')
    set ballooneval
    setlocal balloonexpr=clang_type_inspector#balloon_expr()
endif
