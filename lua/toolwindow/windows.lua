local Terminal  = require('toggleterm.terminal').Terminal
local Windows = {}
local validate = require('toolwindow.validate')

validate.validate()


local function standard_close(plugin)
    plugin.close()
end

local function get_tool(name, plugin, close_fn, open_fn)
    return {
        plugin = plugin,
        name = name,
        close_fn = close_fn,
        open_fn = open_fn
    }
end

local function open_watchexecterm(plugin, args)
    if plugin == nil then
        plugin = Terminal:new({
            cmd = "watchexec --clear -e " .. args.filetype .. ' "clear ; '.. args.cmd .. '"',
            hidden = true,
        })
    end
    plugin:open()
    return plugin
end


local function open_term(plugin, args)
    _ = args
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
    if plugin == nil then return end
    if plugin:is_open() then
        plugin:close()
    end
    return
end


local function standard_open(plugin, args)
    _ = args
    plugin.open()
end



-- Public Methods

local function close()
    for _, value in pairs(Windows) do
        if value.plugin ~= nil then
            value.close_fn(value.plugin)
        end
    end
end

local function open_window(name, args)
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
      register("watchexecterm", nil, term_close, open_watchexecterm)
      register("term", nil, term_close, open_term)
      register("trouble", require("trouble"), standard_close, standard_open)
end
register_builtin()

return {
    open_window = open_window,
    close = close,
    register = register,
}
