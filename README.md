# toolwindow.nvim

Easy management of a toolwindow.

## ✨ Features

* Manage toolwindow with builtin support for tools:
    - Run code on save
    - View diagnostics
    - Launch terminal
* Load custom tool windows to manage
* Configure auto code run per file type

## Requirements

- Neovim >= 0.5.0 for lua support
- [watchexec](https://github.com/watchexec/watchexec) if you want live test execution
- [trouble.nvim](https://github.com/folke/trouble.nvim) for a diagnostics window
- [nvim-toggleterm.lua]( https://github.com/akinsho/nvim-toggleterm.lua ) for a terminal and watchexec support.

## 📦 Installation

Toolwindow includes a file watcher that can be used to execute tests. If you
want to utilize the `watchexecterm` feature you should install watchexec.

Install using the plugin with `:WatchexecInstall`

or

```sh
cargo install watchexec-cli
```

The plugin uses [ trouble.nvim ]( https://github.com/folke/trouble.nvim ) as a diagnostic tool and [ nvim-toggleterm.lua ]( https://github.com/akinsho/nvim-toggleterm.lua ) to add live test execution and an intractable terminal to the tool window.

Install with prefered package manager:

### [vim-plug](https://github.com/junegunn/vim-plug)

```sh
Plug 'folke/trouble.nvim'
Plug 'akinsho/nvim-toggleterm.lua'
Plug 'ethanjwright/toolwindow.nvim'
```

## ⚙️ Configuration

Configure closing the toolwindow, opening trouble, or opening a window.

```vim
nmap <silent><Leader>bc :lua require("toolwindow").close()<CR>
nmap <silent><Leader>bd :lua require("toolwindow").open_window("trouble", nil)<CR>
nmap <silent><Leader>bt :lua require("toolwindow").open_window("term", nil)<CR>
```

Configure live test execution per language

```vim
autocmd FileType python nnoremap <Leader>bl :lua require("toolwindow").open_window("watchexecterm", {filetype = "py", cmd = "pytest"})<CR>
```

### Plugin API


- open_window(name, args) - open a registered window, pass a table of args to the open function
- close() - close current open window if any is open
- register(name, plugin, close_fn, open_fn) - register a new window manager to be tracked

### Register your own tools to be managed

Note: the following examples are in lua, if you are adding them to your
init.vim wrap them in:

```vim
lua << EOF
-- lua here
EOF
```


A standard terminal

```lua
local Terminal  = require('toggleterm.terminal').Terminal
local windows = require("toolwindow")
local function open_fn(plugin, args)
    _ = args
    plugin:open()
end

local function close_fn(plugin)
    plugin.close()
end

-- params: name, plugin, function to close window, function to open window
windows.register("term", Terminal:new({hidden = true}), close_fn, open_fn)
```

A silly example, cowsay

```lua
local Terminal  = require('toggleterm.terminal').Terminal
local windows = require("toolwindow")
local function cowsay_open(plugin, args)
    _ = args
    if plugin == nil then
      plugin = Terminal:new({
          cmd = "fortune | cowsay",
          hidden = true,
          on_close = function(term)
              vim.cmd("Ending cowsay...")
          end,
      })
    end
    plugin:open()
    return plugin
end

local function cowsay_close(plugin)
    if plugin:is_open() then
        plugin:close()
    end
end

-- Plugin is nil here as the terminal will be created on each open
windows.register("cowsay", nil, cowsay_close, cowsay_open)
```
