# LSPLINKS

> Basic support for document links for neovim.

Example Usage:

``` lua
vim.keymap.set("n", "gd", function()
    local lsplinks = require("lsplinks")
    if not lsplinks.lsp_has_capability("definitionProvider") and lsplinks.lsp_has_capability("documentLinkProvider") then
        lsplinks.jump()
    else
        vim.lsp.buf.definition()
    end
end)
```
