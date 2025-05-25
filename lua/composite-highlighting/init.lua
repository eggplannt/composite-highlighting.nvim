local M = {}

local config = require 'composite-highlighting.config'
local main

M.setup = function(opts)
  config.setup_options(opts)

  if not main then
    main = require 'composite-highlighting.main'
  end
  main.init()
end

return M
