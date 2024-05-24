local util = require("vim.lsp.util")
local log = require("vim.lsp.log")
local api = vim.api
local M = {}

---@class lsp.Position
---@field line integer
---@field character integer

---@class lsp.Range
---@field start lsp.Position
---@field end lsp.Position

---@class lsp.DocumentLink
---@field range lsp.Range
---@field target string

---@class lsplinks.Options
---@field hl_group string | nil
---@field highlight boolean | nil

---@type table<integer, lsp.DocumentLink[]>
local links_by_buf = {}

---@type lsplinks.Options
local options = {
  hl_group = "Underlined",
  highlight = true,
}

---@type integer
local ns = api.nvim_create_namespace("lsplinks")

---@return lsp.Position
local function get_cursor_pos()
  local cursor = api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- adjust line number for 0-indexing
  local character = util.character_offset(0, line, cursor[2], "utf-8")
  return { line = line, character = character }
end

---@param pos lsp.Position
---@param range lsp.Range
---@return boolean
local function in_range(pos, range)
  if pos.line > range.start.line and pos.line < range["end"].line then
    return true
  elseif pos.line == range.start.line and pos.line == range["end"].line then
    return pos.character >= range.start.character and pos.character <= range["end"].character
  elseif pos.line == range.start.line then
    return pos.character >= range.start.character
  elseif pos.line == range["end"].line then
    return pos.character <= range["end"].character
  else
    return false
  end
end

local augroup = api.nvim_create_augroup("lsplinks", { clear = true })

--- Setup autocommands for refreshing links
---@param opts lsplinks.Options | nil
function M.setup(opts)
  opts = opts or {}
  if opts.hl_group ~= nil then
    options.hl_group = opts.hl_group
  end
  if opts.highlight ~= nil then
    options.highlight = opts.highlight
  end
  api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "CursorHold", "LspAttach" }, {
    group = augroup,
    callback = M.refresh,
  })
end

--- Return the first link under the cursor.
---
---@return lsp.DocumentLink | nil
function M.current()
  local cursor = get_cursor_pos()
  for _, link in ipairs(M.get()) do
    if in_range(cursor, link.range) then
      return link
    end
  end
  return nil
end

--- Open the link under the cursor if one exists.
--- The return value indicates if a link was found.
---
---@param link lsp.DocumentLink | nil
---@return boolean
function M.open(link)
  link = link or M.current()
  if not link then
    return false
  end
  local uri = link.target
  if not uri then
    vim.notify_once("lsplinks: documentLink/resolve is not implemented", vim.log.levels.ERROR)
    return nil
  end
  if link.target:find("^file:/") then
    util.jump_to_location({ uri = uri }, "utf-8", true)
    local line_no, col_no = uri:match(".-#(%d+),(%d+)")
    if line_no then
      api.nvim_win_set_cursor(0, { tonumber(line_no), tonumber(col_no) - 1 })
    end
  else
    vim.ui.open(uri)
  end
  return true
end

-- Refresh the links for the current buffer
function M.refresh()
  local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/documentLink" })
  if #clients == 0 then
    return
  end
  -- TODO: support more than one client
  local params = { textDocument = util.make_text_document_params() }
  clients[1].request("textDocument/documentLink", params, function(err, result, ctx)
    if err then
      log.error("lsplinks", err)
      return
    end
    if not links_by_buf[ctx.bufnr] then
      api.nvim_buf_attach(ctx.bufnr, false, {
        on_detach = function(b)
          links_by_buf[b] = nil
        end,
        on_lines = function(_, b, _, first_lnum, last_lnum)
          api.nvim_buf_clear_namespace(b, ns, first_lnum, last_lnum)
        end,
      })
    end
    links_by_buf[ctx.bufnr] = result
    if options.highlight then
      M.display()
    end
  end)
end

--- Get links for bufnr
---@param bufnr integer | nil
---@return lsp.DocumentLink[]
function M.get(bufnr)
  bufnr = bufnr or 0
  if bufnr == 0 then
    bufnr = api.nvim_get_current_buf()
  end
  return links_by_buf[bufnr] or {}
end

--- Highlight links in the current buffer
function M.display()
  api.nvim_buf_clear_namespace(0, ns, 0, -1)
  for _, link in ipairs(M.get()) do
    -- sometimes the buffer is changed before we get here and the link
    -- ranges are invalid, so we ignore the error.
    pcall(api.nvim_buf_set_extmark, 0, ns, link.range.start.line, link.range.start.character, {
      end_row = link.range["end"].line,
      end_col = link.range["end"].character,
      hl_group = options.hl_group,
    })
  end
end

return M
