local M = {}

local config = require 'composite-highlighting.config'

M.init = function()
  local function get_extension(filename)
    local ext = filename:match '^.*%.([^%.\\/]+)$'
    return ext or ''
  end

  -- Predefined map for common extensions to filetypes.
  -- This is particularly useful for extensions where vim.filetype.match({filename = ...})
  -- might return nil due to content-sniffing logic in their filetype rules.
  -- The goal is to map an extension string to a standard Neovim filetype string.
  local extension_to_filetype_map = {
    ts = 'typescript',
    tsx = 'typescriptreact',
    js = 'javascript',
    jsx = 'javascriptreact',
    py = 'python',
    rb = 'ruby',
    sh = 'sh',
    html = 'html',
    css = 'css',
    scss = 'scss',
    json = 'json',
    yaml = 'yaml',
    yml = 'yaml',
    xml = 'xml',
    md = 'markdown',
    go = 'go',
    java = 'java',
    c = 'c',
    cpp = 'cpp',
    cs = 'cs',
    lua = 'lua',
    php = 'php',
    perl = 'perl',
    pl = 'perl',
    rust = 'rust',
    rs = 'rust',
    swift = 'swift',
    kt = 'kotlin',
    -- Add more common extensions as needed
  }

  local parser_to_node = {
    gotmpl = 'text',
    blade = 'text',
    jinja = 'words',
    liquid = 'template_content',
  }

  for _, language in ipairs(config.options.languages) do
    local directive_name = string.format('inject-%s!', language.parser)
    vim.treesitter.query.add_directive(directive_name, function(_, _, bufnr, _, metadata)
      local full_fname = vim.api.nvim_buf_get_name(bufnr)
      if not full_fname or full_fname == '' then
        return
      end
      local fname_basename = vim.fs.basename(full_fname)
      -- Strip the ".tmpl" extension (5 characters)
      local base_name_for_ft = fname_basename:sub(1, #fname_basename - #language.extension - 1)
      if base_name_for_ft == '' then
        return
      end
      local ft
      -- Attempt 1: Use vim.filetype.match on the full base name
      -- (e.g., "index.html", "component.ts", "Makefile")
      ft = vim.filetype.match { filename = base_name_for_ft }
      if ft then
        metadata['injection.language'] = ft
        return
      end
      -- Attempt 2: If direct match failed, extract the extension from base_name_for_ft
      -- and try vim.filetype.match with a generic "file.ext" filename.
      local base_ext = get_extension(base_name_for_ft)
      if base_ext ~= '' then
        ft = vim.filetype.match { filename = 'file.' .. base_ext }
        if ft then
          metadata['injection.language'] = ft
          return
        end
        -- Attempt 3: If vim.filetype.match with "file.ext" also failed,
        -- use the predefined map as a fallback for common/known extensions.
        if extension_to_filetype_map[base_ext] then
          ft = extension_to_filetype_map[base_ext]
          metadata['injection.language'] = ft
          return
        end
      end
    end, {})
    local filetypes = vim.treesitter.language.get_filetypes(language.parser)
    if not filetypes then
      vim.notify(string.format('composite-highlighting: %s parser configs are missing', language.parser))
      return
    end

    local ft = filetypes[1]
    if not ft then
      vim.notify('no ft', vim.log.levels.ERROR)
      goto continue
    end
    vim.filetype.add {
      extension = {
        [language.extension] = ft,
      },
    }
    local node = language.injection_node or parser_to_node[language.parser] or 'text'
    local query = [[
          ((]] .. node .. [[) @injection.content
            (#]] .. directive_name .. [[)
            (#set! injection.combined))
        ]]
    vim.notify(ft .. query)
    vim.treesitter.query.set(ft, 'injections', query)
    ::continue::
  end
end
return M
