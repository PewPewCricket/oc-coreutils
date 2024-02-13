local shell = require("shell")
local tty = require("tty")
local text = require("text")
local fs = require("filesystem")
local sh = require("sh")
local term = require("term")

local args = shell.parse(...)
local user = "root"
local hostname = "computer"

term.clear()

if fs.exists("/etc/hostname") then
  local f = io.open("/etc/hostname", "r")
  hostname = f:read()
  f:close()
  if hostname == " " or hostname == nil then
    io.stderr:write("Invalid Hostname")
    hostname = "computer"
    os.sleep(1)
  end
else
  io.stderr:write("Please select a hostname!")
  os.sleep(1)
end

shell.prime()

if #args == 0 then
  local has_profile
  local input_handler = {hint = sh.hintHandler}
  while true do
    if io.stdin.tty and io.stdout.tty then
      if not has_profile then -- first time run AND interactive
        has_profile = true
        dofile("/etc/profile.lua")
      end
      if tty.getCursor() > 1 then
        io.write("\n")
      end
        io.write("[" .. user .. "@" .. hostname .. " " .. sh.expand(os.getenv("PWD") .. "] " .. "$ "))
    end
    tty.window.cursor = input_handler
    local command = io.stdin:readLine(false)
    tty.window.cursor = nil
    if command then
      command = text.trim(command)
      if command == "exit" then
        return
      elseif command ~= "" then
        --luacheck: globals _ENV
        local result, reason = sh.execute(_ENV, command)
        if not result and reason then
          io.stderr:write(tostring(reason), "\n")
        end
      end
    elseif command == nil then -- false only means the input was interrupted
      return -- eof
    end
  end
else
  -- execute command.
  return sh.execute(...)
end
