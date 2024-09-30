local overseer = require 'overseer'
local constants = require 'overseer.constants'
local TAG = constants.TAG

---@type overseer.TemplateFileDefinition
local tmpl = {
  params = {
    args = { type = 'list', delimiter = ' ' },
    cwd = { optional = true },
  },
  builder = function(params)
    return {
      cmd = { 'zig' },
      args = params.args,
      cwd = params.cwd,
      components = { { 'on_output_quickfix', open = true }, 'default' },
    }
  end,
  condition = {
    filetype = { 'zig' },
  },
}

---@param opts overseer.SearchParams
---@return nil|string
local function get_build_file(opts)
  return vim.fs.find('build.zig', { upward = true, type = 'file', path = opts.dir })[1]
end

return {
  generator = function(opts, cb)
    local file = vim.fn.expand '%:p'
    local zig_dir = vim.fs.dirname(assert(get_build_file(opts)))
    local ret = {}

    local commands = {
      { args = { 'build' }, tags = { TAG.BUILD } },
      { args = { 'run', file }, tags = { TAG.RUN } },
      { args = { 'test', file }, tags = { TAG.TEST } },
    }
    local roots = {
      { {
        cwd = zig_dir,
      } },
    }
    for _, root in ipairs(roots) do
      for _, command in ipairs(commands) do
        table.insert(
          ret,
          overseer.wrap_template(tmpl, {
            name = string.format('zig %s', table.concat(command.args, ' ')),
            tags = command.tags,
          }, { args = command.args, cwd = root.cwd })
        )
      end
      table.insert(ret, overseer.wrap_template(tmpl, { name = 'zig' }, { cwd = root.cwd }))
    end
    cb(ret)
  end,
}
