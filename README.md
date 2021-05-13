# toolwindow.nvim

Easy management of a toolwindow.

## Installation

Toolwindow includes a file watcher that can be used to execute tests. If you
want to utilize the `watchexecterm` feature you should install watchexec.

```sh
cargo install watchexec-cli
```

The plugin uses (trouble.nvim)[https://github.com/folke/trouble.nvim] as a diagnostic tool and (nvim-toggleterm.lua)[https://github.com/akinsho/nvim-toggleterm.lua] to add live test execution and an intractable terminal to the tool window.

```sh
Plug 'folke/trouble.nvim'
Plug 'akinsho/nvim-toggleterm.lua'
Plug 'ethanjwright/toolwindow.nvim'
```

## Usage

Configure closing the toolwindow, opening trouble, or opening a window.

```
nmap <silent><Leader>bc :lua require("toolwindow").close()<CR>
nmap <silent><Leader>bd :lua require("toolwindow").open_window("trouble", nil)<CR>
nmap <silent><Leader>bt :lua require("toolwindow").open_window("term", nil)<CR>
```

Configure live test execution per language

```
autocmd FileType python nnoremap <Leader>bl :lua require("toolwindow").open_window("watchexecterm", {filetype = "py", cmd = "pytest"})<CR>
```
