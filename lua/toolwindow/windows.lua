local Terminal = nil
local Trouble = nil
local Todo = nil
local Windows = {}
local autobuild = require('toolwindow.validate')
local api = vim.api
local parent = nil

local function standard_close(plugin)
    if plugin ~= nil and plugin.close ~= nil then
        plugin.close()
    end
end

local function get_tool(name, plugin, close_fn, open_fn)
    return {
        plugin = plugin,
        name = name,
        close_fn = close_fn,
        open_fn = open_fn
    }
end

local function validate_toggleterm()
    if Terminal == nil then
        Terminal = require('toggleterm.terminal').Terminal
        if Terminal == nil then
            api.nvim_err_writeln("toggleterm plugin not installed!")
        end
    end
end

local function has_trouble()
    if Trouble == nil then
        Trouble = require("trouble")
        if Trouble == nil then
            return false
        end
    end
    return true
end

local function validate_trouble()
  if not has_trouble() then
    api.nvim_err_writeln("trouble.nvim not installed!")
  end
end

local function set_parent()
  parent = vim.api.nvim_get_current_win()
end

local function goto_parent()
    if parent and vim.api.nvim_win_is_valid(parent) then
      vim.api.nvim_set_current_win(parent)
    end
end

local function open_autobuild(plugin, args)
    validate_toggleterm()
    autobuild.validate()
    if plugin == nil then
        plugin = Terminal:new({
            cmd = "watchexec --clear -e " .. args.filetype .. ' "clear ; '.. args.cmd .. '"',
            hidden = true,
        })
    end
    plugin:open()
    vim.cmd('stopinsert')
    vim.cmd('normal! G')
    goto_parent()
    vim.cmd('stopinsert')
    return plugin
end

local function open_term(plugin, args)
    _ = args
    validate_toggleterm()
    if plugin == nil then
        plugin = Terminal:new({
            hidden = true,
            on_exit = function(job, data, name)
                _, _, _ = job, data, name
                vim.cmd("echo exited")
            end,
        })
    end
    plugin:open()
    return plugin
end

local function term_close(plugin)
    if plugin ~= nil and plugin.is_open ~= nil and plugin.close ~= nil then
        if plugin:is_open() then
            plugin:close()
        end
    end
end

local function trouble_open(plugin, args)
    validate_trouble()
    if args == nil or args.mode == nil then
        args = { mode = "lsp_workspace_diagnostics" }
    end
    if plugin == nil then
        Trouble.open(args)
        goto_parent()
        return Trouble
    else
        plugin.open(args)
        goto_parent()
    end
end

local function validate_todo()
    if Todo == nil then
        Todo = require("todo-comments")
        if Todo == nil then
            api.nvim_err_writeln("todo-comments.nvim not installed!")
        end
    end
end

local function todo_open(plugin, args)
    validate_trouble()
    validate_todo()
    _ = args
    return trouble_open(plugin, {mode = "todo"})
end

local function qf_open(plugin, args)
    _, _ = plugin, args
    vim.cmd("copen")
    goto_parent()
end

local function qf_close(plugin)
    _ = plugin
    vim.cmd("cclose")
end

-- Public Methods

local function close()
    for _, value in pairs(Windows) do
        if value.plugin ~= nil then
            value.close_fn(value.plugin)
        else
            value.close_fn("")
        end
    end
end

local function open_window(name, args)
    if args ~= nil and args.stay_after_open ~= nil and args.stay_after_open then
    else
      set_parent()
    end
    close()
    local update_plugin = Windows[name].open_fn(Windows[name].plugin, args)
    if update_plugin ~= nil then
        Windows[name].plugin = update_plugin
    end
end

local function register(name, plugin, close_fn, open_fn)
    if Windows[name] == nil then
        local tool = get_tool(name, plugin, close_fn, open_fn)
        Windows[tool.name] = tool
    end
end

-- register default utilities

local function register_builtin()
      register("autobuild", nil, term_close, open_autobuild)
      register("term", nil, term_close, open_term)
      register("trouble", nil, standard_close, trouble_open)
      register("todo", nil, standard_close, todo_open)
      register("quickfix", nil, qf_close, qf_open)
end

register_builtin()

return {
    open_window = open_window,
    close = close,
    register = register,
}
