return {
  name = 'zig build',
  builder = function()
    local file = vim.fn.expand '%:p'
    return {
      cmd = { 'zig', 'build' },
      args = { file },
      components = { { 'on_output_quickfix', open = true }, 'default' },
    }
  end,
  condition = {
    filetype = { 'zig' },
  },
}
