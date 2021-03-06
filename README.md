# toolwindow.nvim

Easy management of a toolwindow.

There are many great plugins being developed that are toggled to occupy the
toolwindow space in neovim. Individually each is great, but managing opening
and closing them with keybinds can be tedious. Here is a fix.

## ✨ Features

* Manage toolwindow with builtin support for tools:
    - Run code on save
    - View diagnostics with [trouble](https://github.com/folke/trouble.nvim)
    - Launch terminal with [toggleterm](https://github.com/akinsho/nvim-toggleterm.lua)
    - Toggle quickfix list
* Load custom tool windows to manage
* Configure auto code run per file type

### Screenshots

Short Demo

![](./screenshots/demo.gif)

Automatically build your project

![](./screenshots/autobuild.png)

View comments in code

![](./screenshots/todo-comments.png)

Open a terminal

![](./screenshots/toggleterm.png)

## Requirements

- Neovim >= 0.5.0 for lua support
- [watchexec](https://github.com/watchexec/watchexec) supports autobuild feature
- [trouble.nvim](https://github.com/folke/trouble.nvim) for a diagnostics window
- [nvim-toggleterm.lua]( https://github.com/akinsho/nvim-toggleterm.lua ) for a terminal and autobuild support.

## 📦 Installation

Toolwindow includes an autobuild feature that can be used to execute tests. If you
want to utilize the `autobuild` feature you should install the dependencies.

Install using the plugin with `:AutobuildInstall`

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

" toggle quickfix list (:copen)
nmap <silent><Leader>bt :lua require("toolwindow").open_window("quickfix", nil)<CR>

" use akinsho/nvim-toggleterm.lua
nmap <silent><Leader>bt :lua require("toolwindow").open_window("term", nil)<CR>

" use folke/trouble.nvim
nmap <silent><Leader>bd :lua require("toolwindow").open_window("trouble", nil)<CR>

" use folke/todo-comments.nvim
nmap <silent><Leader>bn :lua require("toolwindow").open_window("todo", nil)<CR>
```

Configure live test execution per language

```vim
autocmd FileType python nnoremap <Leader>bl :lua require("toolwindow").open_window("autobuild", {filetype = "py", cmd = "pytest"})<CR>
```

Most calls will return you to your current window after running. To change this, set stay_after_open in the args

```vim
nmap <silent><Leader>bd :lua require("toolwindow").open_window("trouble", {stay_stay_after_open = true})<CR>
```

### Plugin API

`open_fn(plugin, args)` - this is called by the toolwindow to open the given tool. A reference to the plugin is passed, as well as the arg table that was passed on the open_window call

`close_fn(plugin)` - this is called by the toolwindow to close the given tool. A reference to the tool plugin is passed.



- `open_window(name, args)` - open a registered window, pass a table of args to the open function
- `close()` - close current open window if any is open
- `register(name, plugin, close_fn, open_fn)` - register a new window manager to be tracked

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
    plugin:close()
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
          on_exit = function(job, data, name)
              _, _, _ = job, data, name
              vim.cmd("echo finished cowsay")
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
