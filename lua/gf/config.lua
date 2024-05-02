
---@class DestinationInformation
---@field path  string
---@field line  integer
---@field col   integer

---@alias ExtensionFunction       fun(): DestinationInformation | nil
---@alias ExtensionFunctionTable  ExtensionFunction[]

local M = {}

---@class Options
---@field event { [string]: string }
---@field table ExtensionFunctionTable
local defaults = {
  event = {
    ["gf"]         = "",
    ["gF"]         = "",

    ["<C-w>f"]     = "split",
    ["<C-w><C-f>"] = "split",
    ["<C-w>F"]     = "split",

    ["<C-w>gf"]    = "tab split",
    ["<C-w>gF"]    = "tab split",
  },
  table = { }
}


---@type Options
M.options = {}


---@param options? Options
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
-- vim: foldmethod=marker
