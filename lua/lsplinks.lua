function jump()
  local params = { textDocument = { uri = vim.uri_from_bufnr(0) } }
  vim.lsp.buf_request(0, "textDocument/documentLink", params, function(err, result)
    if err then
      vim.api.nvim_err_writeln(err.message)
      return
    end
    local cursor = get_cursor_pos()
    for _, link in pairs(result) do
      if in_range(cursor, link.range) then
        jump_to_link_target(link.target)
        return
      end
    end
  end)
end

function get_cursor_pos()
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor[1] = cursor[1] - 1 -- Adjust line number for 0-indexing
  cursor[2] = vim.lsp.util.character_offset(0, cursor[1], cursor[2])
  return { line = cursor[1], character = cursor[2] }
end

function in_range(pos, range)
  if pos.line > range.start.line and pos.line < range['end'].line then
    return true
  elseif pos.line == range.start.line and pos.line == range['end'].line then
    return pos.character >= range.start.character and pos.character <= range['end'].character
  elseif pos.line == range.start.line then
    return pos.character >= range.start.character
  elseif pos.line == range['end'].line then
    return pos.character <= range['end'].character
  else
    return false
  end
end

function jump_to_link_target(target)
  local file_uri, line_no, col_no = target:match('(.-)#(%d+),(%d+)')
  vim.lsp.util.jump_to_location({
    uri = file_uri,
    range = {
      start = {
        line = tonumber(line_no),
        character = tonumber(col_no)
      }
    }
  }, "utf-8", true)
end

function lsp_has_capability(name)
  for _, client in ipairs(vim.lsp.buf_get_clients()) do
    local capabilities = client.server_capabilities
    if capabilities[name] then
      return true
    end
  end
  return false
end

return {
  jump = jump,
  lsp_has_capability = lsp_has_capability
}
