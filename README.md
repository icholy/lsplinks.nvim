# LSPLINKS

> Basic support for document links for neovim.
> This includes openapi/swagger $refs when using jsonls.

### Prerequisites:

This plugin requires an existing lsp server which supports document links.
My testing was done using: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls

### Example Configuration:

Replace your existing goto-defintion mapping with the following:

``` lua
vim.keymap.set("n", "gd", function()
    local lsplinks = require("lsplinks")
    if lsplinks.is_only_option() then
        lsplinks.jump()
    else
        vim.lsp.buf.definition()
    end
end)
```
