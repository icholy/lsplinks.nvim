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

---@type table<integer, lsp.DocumentLink[]>
local links_by_buf = {}

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

---@param name string
---@return boolean
local function lsp_has_capability(name)
  for _, client in ipairs(vim.lsp.buf_get_clients()) do
    if client.server_capabilities[name] then
      return true
    end
  end
  return false
end

local augroup = api.nvim_create_augroup("lsplinks", { clear = true })

--- Setup autocommands for refreshing links
function M.setup()
  api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "CursorHold", "LspAttach" }, {
    group = augroup,
    callback = M.refresh,
  })
end

--- Return the link under the cursor.
---
---@return string | nil
function M.current()
  local cursor = get_cursor_pos()
  for _, link in ipairs(M.get()) do
    if in_range(cursor, link.range) then
      return link.target
    end
  end
  return nil
end

--- Return the uri without the fragment
---
---@param uri string
---@return string
local function remove_uri_fragment(uri)
  local fragment_index = uri:find("#")
  if fragment_index ~= nil then
    uri = uri:sub(1, fragment_index - 1)
  end
  return uri
end

--- Open the link under the cursor if one exists.
--- The return value indicates if a link was found.
---
---@param uri string | nil
---@return boolean
function M.open(uri)
  uri = uri or M.current()
  if not uri then
    return false
  end
  if uri:find("^file:/") then
    util.jump_to_location({ uri = remove_uri_fragment(uri) }, "utf-8", true)
    local line_no, col_no = uri:match(".-#(%d+),(%d+)")
    if line_no then
      api.nvim_win_set_cursor(0, { tonumber(line_no), tonumber(col_no) - 1 })
    end
  else
    if vim.ui.open then
      vim.ui.open(uri)
    else
      -- for nvim earlier than 0.10
      local opener
      if vim.fn.has("macunix") == 1 then
        opener = "open"
      elseif vim.fn.has("linux") == 1 then
        opener = "xdg-open"
      elseif vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 then
        opener = "start"
      end
      local openCommand = string.format("%s '%s' >/dev/null 2>&1", opener, uri)
      vim.fn.system(openCommand)
    end
  end
  return true
end

--- Convenience function which opens current link with fallback
--- to default gx behaviour
function M.gx()
  local uri = M.current() or vim.fn.expand("<cfile>")
  M.open(uri)
end

--- Deprecated
function M.jump()
  vim.notify_once("lsplinks: jump is deprecated, use open instead", vim.log.levels.WARN)
  M.open()
end

-- Refresh the links for the current buffer
function M.refresh()
  if not lsp_has_capability("documentLinkProvider") then
    return
  end
  local params = { textDocument = util.make_text_document_params() }
  vim.lsp.buf_request(0, "textDocument/documentLink", params, function(err, result, ctx)
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
    M.display()
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
      hl_group = "Underlined",
    })
  end
end

return M
