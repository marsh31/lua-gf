

local gf = {}

local keyset = vim.keymap.set
local keydel = vim.keymap.del
local gf_config = require("gf.config")


-- local functions {{{

---@class What
---@field try     fun()
---@field catch   fun(exception: string)
---@field finally fun(status: boolean, exception: string)



---try_catch
---@param what What
---@return nil
local function try_catch(what)
  local status, exception = pcall(what.try)
  if not status then
    what.catch(exception)
  end

  if what.finally then
    what.finally(status, exception)
  end
  return exception
end



---get_plug_key
---@param key string User mapping key.
---@return string #Plug mapping key.
local function get_plug_key(key)
  return string.format("<Plug>(lua-gf:%s)", key)
end



---gf action try
---@param func ExtensionFunction  #user defined function
---@param key  string             #build-in key
---@return boolean                #True if the func succeeds, False otherwise.
local function gf_try (func, key)
  local destination_information = func()

  if destination_information ~= nil then
    local event = gf_config.options.event[key]
    if event ~= "" then
      vim.api.nvim_command(event)
    end

    vim.api.nvim_command(string.format("edit %s", destination_information.path))
    vim.api.nvim_command(string.format("normal!%sgg", destination_information.line))
    vim.api.nvim_command(string.format("normal!%s|", destination_information.col))

    return true
  end

  return false
end

---gf action
---@param mode string
---@param key string
local function gf_do (mode, key)
  local errmsg = ""
  local isWorked = false

  try_catch({
    try = function ()
      vim.api.nvim_command(string.format('exe "normal!%s"', string.gsub(key, "<(%a%-%a)>", "\\<%1>")))
      isWorked = true
    end,

    catch = function (exception)
      errmsg = exception

      -- check error message
      try_catch({
        try = function()
          for _, value in ipairs(gf_config.options.table) do
            if gf_try(value, key) then
              isWorked = true
              break
            end
          end
        end,

        catch = function (err)
          errmsg = err
        end
      })
    end
  })

  if not isWorked then
    error(errmsg, 1)
  end
end



local function set_plug_mapping(mode, key)
  local lhs = get_plug_key(key)
  local rhs = function ()
    gf_do(mode, key)
  end

  local option = { remap = true, buffer = false, expr = false, silent = false, unique = false }
  keyset(mode, lhs, rhs, option)
end


local function set_user_mapping(mode, key)
  local lhs = key
  local rhs = get_plug_key(key)
  local option = { remap = false, buffer = false, expr = false, silent = true, unique = false }
  keyset(mode, lhs, rhs, option)
end


local function init_plug_mapping()
  for key, value in pairs(gf_config.options.event) do
    set_plug_mapping("n", key)
    set_plug_mapping("x", key)
  end
end


local function init_user_mapping()
  for key, value in pairs(gf_config.options.event) do
    set_user_mapping("n", key)
    set_user_mapping("x", key)
  end
end

-- }}}


-- 
-- setup {{{


--- @param options? Options
function gf.setup(options)
  gf_config.setup(options)

  init_plug_mapping()
  init_user_mapping()
end


---Unmap key.
---@param key string Key to unmap.
function gf.unmap(key)
  keydel("n", key)
  keydel("x", key)
end


---Unmap all keys
function gf.unmap_all()
  for key, _ in pairs(gf_config.options.event) do
    gf.unmap(key)
    gf.unmap(key)
  end
end

-- }}}

return gf
-- vim: foldmethod=marker
