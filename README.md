Inspect `auto` with Power of Clang
==================================

This plugin inspects `auto` declarations in your Vim.  You can know the type of `auto` declarations easily.

![Screenshot](http://gifzo.net/BGqCKUIZ2OA.gif)

## Installation

This plugin depends on [libclang-vim](https://github.com/rhysd/libclang-vim).  This is a wrapper of libclang.  Please see [README](https://github.com/rhysd/libclang-vim/blob/master/README.md) to install it.

After installing libclang-vim, you can install this plugin like other plugins.

I recommend to use modern Vim plugin managers like [vundle](https://github.com/gmarik/vundle) or [neobundle.vim](https://github.com/Shougo/neobundle.vim).

Below neobundle.vim setting has done all successfully.

```vim
NeoBundleLazy 'rhysd/libclang-vim', {
            \ 'build' : {
            \       'windows' : 'echo "Please build manually"',
            \       'mac' : 'make',
            \       'unix' : 'make',
            \   }
            \ }

NeoBundleLazy 'rhysd/clang-type-inspector.vim', {
            \ 'depends' : 'rhysd/libclang-vim',
            \ 'autoload' : {
            \       'filetypes' : 'cpp'
            \   }
            \ }
```

## Usage

### Mapping

You can set `<Plug>(clang-inspect-type-at-cursor)` to your favorite mapping.  For example, below setting maps it to `<C-t>`.

```vim
augroup clang-inspect-type-mapping
    autocmd!
    autocmd FileType cpp nmap <C-t> <Plug>(clang-inspect-type-at-cursor)
augroup END
```

### Automatic Inspection

As default, when the cursor is on auto-declaration, type of the declaration is displayed.
If you want to disable this feature, set `g:clang_type_inspector#automatic_inspection` to `0`.

### Balloon (gVim only)

gVim can show balloon which displays the information where the mouse is pointing(See `:help balloon-eval`).  This plugin displays the type using balloon.  When you point the specific location of buffer with the mouse pointer, a balloon would be launched and show the type.  This feature is enabled as default. If you want to disable this feature, set `g:clang_type_inspector#disable_balloon` to `1`.

### Function

You can get the type with below function.

```
clang_type_inspector#inspect_type_at({line}, {col}, {option})
```

`{line}` and `{col}` is line and column of the source.

`{option}` is a dictionary.  If `{option}` has `file` key,  its value specifies the file name of source.  If `{option}` has `bufnr` key, its value specifies the buffer number of source.  If both `file` and `bufnr` are not specified, the current buffer is used as the source to inspect.

## License

    The MIT License (MIT)

    Copyright (c) 2014 rhysd

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

