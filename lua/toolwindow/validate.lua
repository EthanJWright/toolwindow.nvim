local api = vim.api
local M = {}

function M.validate()
  if vim.fn.executable("watchexec") == 0 then
    api.nvim_err_writeln("watchexec is not installed. Call :WatchexecInstall to install it\n")
    return false
  end
  return true
end

local function call_cargo_command()
  local cmd = {"cargo", "install", "watchexec-cli"}
  print("A message will print once install is complete, it can may take up to 20 seconds...")
  vim.fn.jobstart(cmd, {
    on_exit = function(_, d, _)
      if d == 0 then
        api.nvim_out_write("latest watchexec installed!\n")
        return
      end
      api.nvim_err_writeln("failed to install watchexec\n")
    end,
  })
end

function M.download_watchexec()
  if not vim.fn.executable("cargo") == 0 then
    api.nvim_err_writeln("Cargo not installed. Please provide it first")
  end

  if vim.fn.executable("watchexec") == 1 then
    local answer = vim.fn.input(
                     "latest watchexec already installed, do you want update? Y/n = ")
    answer = string.lower(answer)
    while answer ~= "y" and answer ~= "n" do
      answer = vim.fn.input("please answer Y or n = ")
      answer = string.lower(answer)
    end

    if answer == "n" then
      api.nvim_out_write("\n")
      return
    end
    api.nvim_out_write("updating watchexec..\n")
  else
    print("installing watchexec..")
  end
  call_cargo_command()
end

function M.create_commands()
  vim.cmd("command! WatchexecInstall :lua require('toolwindow.validate').download_watchexec()")
end

return M
