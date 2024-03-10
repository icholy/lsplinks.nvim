# LSPLINKS

> Support for document links for neovim.

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

### Demo 1:

Jump to `$ref` links in swagger/openapi files.

![](https://private-user-images.githubusercontent.com/943597/311519883-3f41f659-7b4a-407d-900b-2070ded22e6c.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTAwODM2MjksIm5iZiI6MTcxMDA4MzMyOSwicGF0aCI6Ii85NDM1OTcvMzExNTE5ODgzLTNmNDFmNjU5LTdiNGEtNDA3ZC05MDBiLTIwNzBkZWQyMmU2Yy5naWY_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQwMzEwJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MDMxMFQxNTA4NDlaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0yZWY3NDJlNzM0Yjg4ZjY2YzdiN2MxMzJiYmJmYzNiMjJhMzM4MzA5NDNjYjU2YjQ0ZTQ1OWQ1NDRjMDVmZDJhJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCZhY3Rvcl9pZD0wJmtleV9pZD0wJnJlcG9faWQ9MCJ9.zL6arz5Yy2w30xoH87aVexN82vgqYWVqI0sOjSrRhpM)

### Demo 2: 

Open https://pkg.go.dev from your `go.mod` or import statements.

![](https://private-user-images.githubusercontent.com/943597/311519889-d96e39b5-508b-4efb-ac33-044de88dacce.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTAwODM2MjksIm5iZiI6MTcxMDA4MzMyOSwicGF0aCI6Ii85NDM1OTcvMzExNTE5ODg5LWQ5NmUzOWI1LTUwOGItNGVmYi1hYzMzLTA0NGRlODhkYWNjZS5naWY_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQwMzEwJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MDMxMFQxNTA4NDlaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0xMDRlNmQwNjVmMTI0MTQ3M2Y5ODg0ZTA0OWRkZmRjMDJmNzcyZTRlMDVkOTY3YmZiNGU5NDhiMTVkMTlhMTNlJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCZhY3Rvcl9pZD0wJmtleV9pZD0wJnJlcG9faWQ9MCJ9.YfjiA1GRBqOQZXQzC6Oh2mtz8Sycr2zsQmzM1u9dCMY)
