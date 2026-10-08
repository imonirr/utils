_G.utils = {}

function utils.print_and_clear(text, delay)
  local local_print = _G.old_print or print

  local_print(text)
  vim.fn.timer_start(delay, function()
    local_print("")
  end)
end
