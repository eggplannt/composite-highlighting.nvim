local M = {}

--- @alias Language {parser: string, extension: string, injection_node: string?}

--- @alias Options { languages: Language[] }

--- @type Options
M.default_options = {
  languages = {},
}

--- @type Options
M.options = {}

function M.setup_options(user_opts)
  user_opts = user_opts or {}
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(M.default_options), user_opts)

  local i = 1
  local l = #M.options.languages
  while i <= l do
    local language = M.options.languages[i]

    if not language.parser then
      vim.notify('composite-highlighting: language parser does not exist.', vim.log.levels.WARN)
      table.remove(M.options.languages, i)
      l = l - 1
      goto continue
    end
    if not language.extension then
      language.extension = language.parser
    end
    if type(language.parser) ~= 'string' then
      vim.notify('composite-highlighting: language parser must be a string.', vim.log.levels.WARN)
      table.remove(M.options.languages, i)
      l = l - 1
      goto continue
    end
    if type(language.extension) ~= 'string' then
      vim.notify('composite-highlighting: language extention must be a string.', vim.log.levels.WARN)
      table.remove(M.options.languages, i)
      l = l - 1
      goto continue
    end
    if language.injection_node and type(language.injection_node) ~= 'string' then
      vim.notify('composite-highlighting: language injection_node must be a string.', vim.log.levels.WARN)
      table.remove(M.options.languages, i)
      l = l - 1
      goto continue
    end
    local filetypes = vim.treesitter.language.get_filetypes(language.parser)
    if not filetypes then
      vim.notify(string.format('composite-highlighting: %s parser is not installed', language.parser),
        vim.log.levels.WARN)
      table.remove(M.options.languages, i)
      goto continue
    end
    i = i + 1
    ::continue::
  end
end

return M
