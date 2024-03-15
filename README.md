# LSPLINKS

> Support for [document links](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentLink) for neovim **0.9+**.

### Usage

The default behaviour of [gx](https://neovim.io/doc/user/various.html#gx) is described in the neovim help as:

> Opens the current filepath or URL (decided by
> `<cfile>`, 'isfname') at cursor using the system
> default handler, by calling vim.ui.open().

This plugin extends this behaviour to support LSP document links.

### Prerequisites:

An LSP server which supports `textDocument/documentLink`.

### Configuration:

Call `setup` to initialise the plugin:

``` lua
local lsplinks = require("lsplinks")
lsplinks.setup()
vim.keymap.set("n", "gx", lsplinks.gx)
```

### Lazy Configuration:

``` lua
{
    "icholy/lsplinks.nvim",
    setup = function()
        local lsplinks = require("lsplinks")
        lsplinks.setup()
        vim.keymap.set("n", "gx", lsplinks.gx)
    end
}
```

### Default Configuration:

``` lua
lsplinks.setup({
    highlight = true,
    hl_group = "Underlined",
})
```

### Demo 1:

Jump to `$ref` links in swagger/openapi files.

![](https://i.imgur.com/oSDPU1e.gif)

### Demo 2: 

Open https://pkg.go.dev from your `go.mod` or import statements.

![](https://i.imgur.com/z0Kpslr.gif)
