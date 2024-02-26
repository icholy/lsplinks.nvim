# LSPLINKS

> Support for document links for neovim.
> This includes openapi/swagger $refs when using jsonls.

### Prerequisites:

This plugin requires an existing lsp server which supports document links.
My testing was done using: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls

### Configuration:

Call `setup` to initialise the plugin:

``` lua
require("lsplinks").setup()
```

Replace the `gx` mapping with the following:

``` lua
vim.keymap.set("n", "gx", require("lsplinks").gx)
```

### Lazy Configuration:

``` lua
{
    "icholy/lsplinks.nvim",
    config = function()
        local lsplinks = require("lsplinks")
        lsplinks.setup()
        vim.keymap.set("n", "gx", lsplinks.gx)
    end
}
```

### Demo

![](./tty.gif)
