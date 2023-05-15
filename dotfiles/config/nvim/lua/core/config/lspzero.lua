local M = {}

function M.setup()

  local lsp = require("lsp-zero")

  lsp.preset("recommended")

  lsp.preset({
    name = 'minimal',
    set_lsp_keymaps = {omit = {'<F4>'}},
    manage_nvim_cmp = true,
    suggest_lsp_servers = false,
  })
  --
  lsp.ensure_installed({
    'tsserver',
    'eslint',
    'jdtls',
  })

  -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#default-keybindings

  -- (Optional) Configure lua language server for neovim
  lsp.nvim_workspace()
  lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr }
    local bind = vim.keymap.set

  --  bind("n", "<leader>do", '<cmd> lua vim.lsp.buf.code_action()<cr>', opts)

  --[[
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.lsp.buf.open_float() end, opts)
    vim.keymap.set("n", "[g", function() vim.lsp.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "]g", function() vim.lsp.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "<C-k>", function() vim.lsp.buf.signature_help() end, opts)
  --]]
  end)


  lsp.setup()
  --[[
  nnoremap <silent> K :call CocAction('doHover')<CR>
  " show diagnostic
  nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
  " navigate to errors
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)
  " code action
  nmap <leader>do <Plug>(coc-codeaction)
  " rename symbol
  nmap <leader>rn <Plug>(coc-rename)
  " Give more space for displaying messages.
  set cmdheight=2
  " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
  " delays and poor user experience.
  set updatetime=500
  " Don't pass messages to |ins-completion-menu|.
  set shortmess+=c

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  --]]

end

return M


