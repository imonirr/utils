local M = {}

function M.setup()
  local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
      fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
      vim.cmd [[packadd packer.nvim]]
      return true
    end
    return false
  end


  local packer_bootstrap = ensure_packer()

  return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'ellisonleao/gruvbox.nvim'
    use {
      'nvim-tree/nvim-tree.lua',
      config = function()
        require('core.config.nvimtree').setup()
      end
    }
    use {
      'nvim-tree/nvim-web-devicons',
      config = function()
        require('core.config.nvim-web-devicons').setup()
      end
    }
    use {
      'nvim-lualine/lualine.nvim',
      config = function()
        require('core.config.lualine').setup()
      end
    }
    -- https://github-wiki-see.page/m/nvim-treesitter/nvim-treesitter/wiki/Installation
    use 'nvim-treesitter/nvim-treesitter'

    use {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.0',
      requires = {{ 'nvim-lua/plenary.nvim' }},
      config = function()
        require('core.config.telescope').setup()
      end
    }

    use {
      'numToStr/Comment.nvim',
      config = function()
        require('core.config.comment').setup()
      end
    }

    -- use {
    --   'rmagatti/auto-session',
    --   config = function()
    --     require('core.config.autosession').setup()
    --   end
    -- }

    use {
      'rmagatti/session-lens',
      config = function()
        require('core.config.session-lens').setup()
      end,
      requires = {'rmagatti/auto-session', 'nvim-telescope/telescope.nvim'},
    }



    use({
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            require("rose-pine").setup()
            vim.cmd('colorscheme rose-pine')
        end
    })

    -- using packer.nvim
    -- use {'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}

    use 'mbbil/undotree'
    use {
      'tpope/vim-fugitive',
      config = function()
        require("core.config.vim-fugitive").setup()
      end,
    }

    -- WhichKey
    use {
      "folke/which-key.nvim",
      -- config = function()
      --   require("core.config.whichkey").setup()
      -- end,
    }

    use {
      'williamboman/mason.nvim',
      config = function()
        require('core.config.mason').setup()
      end
    }

    use {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v1.x',
      config = function()
        require('core.config.lspzero').setup()
      end,
      requires = {
        -- LSP Support
        {'neovim/nvim-lspconfig'},             -- Required
        {'williamboman/mason.nvim'},           -- Optional
        {'williamboman/mason-lspconfig.nvim'}, -- Optional

        -- Autocompletion
        {'hrsh7th/nvim-cmp'},         -- Required
        {'hrsh7th/cmp-nvim-lsp'},     -- Required
        {'hrsh7th/cmp-buffer'},       -- Optional
        {'hrsh7th/cmp-path'},         -- Optional
        {'saadparwaiz1/cmp_luasnip'}, -- Optional
        {'hrsh7th/cmp-nvim-lua'},     -- Optional

        -- Snippets
        {'L3MON4D3/LuaSnip'},             -- Required
        {'rafamadriz/friendly-snippets'}, -- Optional
      }
    }


    use {
      "github/copilot.vim",
      config = function()
        require('core.config.copilot').setup()
      end
    }


    -- java
    -- https://alpha2phi.medium.com/neovim-for-beginners-java-6a86cf1a91a5
    use {
      "mfussenegger/nvim-jdtls",
      config = function()
        -- https://github.com/fitrh/init.nvim/blob/main/lua/plugin/jdtls/config.lua
        require("core.config.jdtls").attach()
      end,
      module = "jdtls",
      ft = { "java" }
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end)
end

return M
