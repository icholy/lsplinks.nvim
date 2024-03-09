# LSPLINKS

> Support for document links for neovim.

### Usage

The default behaviour of [gx](https://neovim.io/doc/user/various.html#gx) is described in the neovim help as:

> Opens the current filepath or URL (decided by
> <cfile>, 'isfname') at cursor using the system
> default handler, by calling vim.ui.open().

This plugin extends this behaviour to support LSP document links.

### Prerequisites:

An LSP server which supports `textDocument/documentLink`.

### Configuration:

Call `setup` to initialise the plugin:

``` lua
require("lsplinks").setup()
```

### Demo 1:

Jump to `$ref` links in swagger/openapi files.

![](./demo1.gif)

### Demo 1: 

Open https://pkg.go.dev from your `go.mod` or import statements.

![](./demo2.gif)
