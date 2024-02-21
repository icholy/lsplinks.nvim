# LSPLINKS

> Basic support for document links for neovim.
> This includes openapi/swagger $refs when using jsonls & yamlls.

Example Usage:

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
