# composite-highlighting.nvim

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim >= 0.8](https://img.shields.io/badge/Neovim-%3E%3D%200.8-blueviolet.svg?style=for-the-badge&logo=neovim)](https://neovim.io/)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

`composite-highlighting.nvim` enhances Neovim's Treesitter capabilities by enabling dynamic language injections within template files. It's particularly useful for template systems where the embedded language can vary, determining the correct syntax highlighting based on the template's filename.

For example, a file named `my_page.html.tmpl` can be highlighted as a Go Template (`gotmpl`) on the outside, while the content within specific text nodes is dynamically highlighted as HTML. Similarly, `my_script.js.tmpl` would inject JavaScript.

## ✨ Features

- **Dynamic Language Injection:** Injects syntax highlighting for an inner language based on the template filename (e.g., `*.<inner_ext>.tmpl`).
- **Configurable Template Parsers:** Define which outer template languages and file extensions should use this dynamic injection.
- **Fallback Mechanisms:** Uses `vim.filetype.match` and a predefined extension map to robustly determine the inner language.
- **Treesitter Powered:** Leverages Neovim's Treesitter for accurate and efficient parsing.

## 📸 Screenshot

The following screenshot shows an `index.html.tmpl` file. The Go template syntax is highlighted by the `gotmpl` parser, while the surrounding HTML structure and content are highlighted by the `html` parser. The embedded CSS within the `<style>` tags is also correctly highlighted.

![Composite Highlighting Demo](public/images/example.png)

## 📋 Requirements

- Neovim >= 0.8 (for Treesitter Lua APIs)
- `nvim-treesitter` plugin (as this plugin configures Treesitter injections)
- Treesitter parsers installed for:
  - The **outer** template languages you configure (e.g., `gotmpl`, `eruby`).
  - The **inner** languages you intend to inject (e.g., `html`, `javascript`, `css`).

## 📦 Installation

Install using your favorite plugin manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "eggplannt/composite-highlighting.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("composite-highlighting").setup({
      -- Your configuration here
      languages = {
        { parser = "gotmpl", extension = "tmpl" },
        -- Add other template languages if needed
        -- { parser = "eruby", extension = "erb" },
      },
    })
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "eggplannt/composite-highlighting.nvim",
  requires = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("composite-highlighting").setup({
      -- Your configuration here
      languages = {
        { parser = "gotmpl", extension = "tmpl" },
        -- Add other template languages if needed
      },
    })
  end,
}
```

**Important:** Ensure that the Treesitter parsers for both your template language (e.g., `gotmpl`) and the languages you intend to inject (e.g., `html`, `javascript`, `css`) are installed via `nvim-treesitter`. You can install them with `:TSInstall gotmpl html javascript` etc.

## ⚙️ Configuration

The plugin is configured by calling the `setup` function. The main option is `languages`.

```lua
require("composite-highlighting").setup({
  languages = {
    -- Example 1: Go Templates
    {
      parser = "gotmpl",    -- The Treesitter parser for the outer template language
      extension = "tmpl",   -- The file extension for these template files
                            -- Files like 'index.html.tmpl' will be treated as 'gotmpl'
                            -- and will attempt to inject 'html'.
    },
    -- Example 2: Another template system (e.g., ERuby)
    -- {
    --   parser = "eruby",
    --   extension = "erb", -- Files like 'view.html.erb' would inject 'html'
    -- },
    -- Example 3: If your template parser is the same as its common extension
    -- {
    --   parser = "mycustomtmpl", -- Assumes '.mycustomtmpl' files
    --   -- 'extension' will default to 'mycustomtmpl' if omitted
    -- },
  },
})
```

### `languages` Option

The `languages` option is an array of tables, where each table configures a template type:

- `parser` (string, **required**): The name of the installed Treesitter parser for the outer template language (e.g., `"gotmpl"`, `"eruby"`). The plugin will warn and skip if this parser is not installed.
- `extension` (string, optional): The file extension that identifies these template files (e.g., `"tmpl"`, `"erb"`).
  - If omitted, `extension` defaults to the value of `parser`.
  - The plugin uses this to associate files with the `parser`'s primary filetype and to set up the injection queries.

## 🚀 How it Works

For each configured language in the `languages` option:

1.  The plugin registers the specified `extension` to be recognized as the filetype associated with the `parser` (e.g., `.tmpl` files become `gotmpl`).
2.  It then sets up a Treesitter injection query for this filetype. This query targets generic `(text)` nodes (or similar, depending on the template parser's grammar for raw content).
3.  When such a node is encountered in a file like `filename.<inner_ext>.<outer_ext>` (e.g., `my_page.html.tmpl`), a custom directive `inject-<parser>!` is triggered.
4.  This directive attempts to determine the `<inner_ext>`:
    - It strips the `.<outer_ext>` (e.g., `.tmpl`) from the buffer's filename.
    - It then tries to get the filetype of the remaining part (e.g., `my_page.html`) using:
      1.  `vim.filetype.match({ filename = "my_page.html" })`
      2.  If that fails, it extracts the extension (e.g., `html`) and tries `vim.filetype.match({ filename = "file.html" })`.
      3.  As a final fallback, it consults an internal map of common extensions to filetypes (e.g., `ts` -> `typescript`, `js` -> `javascript`).
5.  The determined inner filetype is then used for syntax highlighting within that `(text)` node.

## 💡 Notes & Troubleshooting

- **Parser Installation:** The most common issue will be missing Treesitter parsers. Ensure both the outer template parser (e.g., `gotmpl`) and any inner language parsers (e.g., `html`, `javascript`, `css`, `python`) you expect to be injected are installed via `nvim-treesitter` (`:TSInstall <parser_name>`).
- **Filename Convention:** The plugin relies on the `filename.<inner_ext>.<outer_ext>` convention for dynamic injection.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Please feel free to open an issue or submit a pull request on [GitHub](https://github.com/eggplannt/composite-highlighting.nvim).

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
