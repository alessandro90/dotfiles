--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]
-- vim options
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.relativenumber = true

-- folding powered by treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter#folding
-- look for foldenable: https://github.com/neovim/neovim/blob/master/src/nvim/options.lua
-- Vim cheatsheet, look for folds keys: https://devhints.io/vim
vim.opt.foldmethod = "expr" -- default is "normal"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- default is ""
vim.opt.foldenable = false -- if this option is true and fold method option is other than normal, every time a document is opened everything will be folded.

-- Set blinking cursor
-- vim.cmd(":set guicursor+=a:blinkwait700-blinkon400-blinkoff250")

-- general
lvim.log.level = "info"
-- lvim.format_on_save = {
--   enabled = true,
--   pattern = "*.lua",
--   timeout = 1000,
-- }
lvim.format_on_save = true
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-a>"] = "ggVG"

-- lvim.keys.normal_mode["H"] = "^"
-- lvim.keys.normal_mode["L"] = "$"
-- lvim.keys.visual_mode["H"] = "^"
-- lvim.keys.visual_mode["L"] = "$"
-- lvim.keys.normal_mode["gt"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["gT"] = ":BufferLineCyclePrev<CR>"

lvim.builtin.which_key.mappings["bC"] = {
    "<cmd>%bd|e#|bd#<cr>", "Close all buffers but the current one"
}

lvim.builtin.which_key.mappings["t"] = {
    name = "Diagnostics",
    t = { "<cmd>TroubleToggle<cr>", "trouble" },
    w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
    d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
    q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
    l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
    r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

lvim.builtin.which_key.mappings["z"] = {
    name = "Fzf",
    f = { "<cmd>FzfLua grep<cr>", "Grep" }
}

lvim.builtin.which_key.mappings["v"] = { "<C-w>v", "split" }
lvim.builtin.which_key.mappings["m"] = { "<c-w>|", "maximize split" }
lvim.builtin.which_key.mappings["M"] = { "<c-w>=", "resize splits" }

--
-- lvim.keys.normal_mode["fzf"] = "FzfLua grep"
-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

-- -- Change theme settings
lvim.colorscheme = "tokyonight-storm"
-- lvim.colorscheme = "lunar"
lvim.transparent_window = true

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
-- lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/configuration/language-features/language-servers>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- -configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- -see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rust_analyzer" })

local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")

local codelldb_path = mason_path .. "bin/codelldb"
local liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb"
local this_os = vim.loop.os_uname().sysname

-- The path in windows is different
if this_os:find "Windows" then
    codelldb_path = mason_path .. "packages\\codelldb\\extension\\adapter\\codelldb.exe"
    liblldb_path = mason_path .. "packages\\codelldb\\extension\\lldb\\bin\\liblldb.dll"
else
    -- The liblldb extension is .so for linux and .dylib for macOS
    liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
end
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })

local pyright_opts = {
    single_file_support = true,
    settings = {
        pyright = {
            disableLanguageServices = false,
            disableOrganizeImports = false
        },
        python = {
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "workspace", -- openFilesOnly, workspace
                typeCheckingMode = "strict",  -- off, basic, strict
                useLibraryCodeForTypes = true
            }
        }
    },
}
require("lvim.lsp.manager").setup("pyright", pyright_opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- linters, formatters and code actions <https://www.lunarvim.org/docs/configuration/language-features/linting-and-formatting>
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    { command = "stylua" },
    { command = "black" },
    {
        command = "prettier",
        extra_args = { "--print-width", "100" },
        filetypes = { "typescript", "typescriptreact" },
    },
    { command = "ocamlformat" },
}
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    { command = "flake8", filetypes = { "python" } },
    {
        command = "shellcheck",
        args = { "--severity", "warning" },
    },
}
local code_actions = require "lvim.lsp.null-ls.code_actions"
code_actions.setup {
    {
        exe = "eslint",
        filetypes = { "typescript", "typescriptreact" },
    },
}

-- Additional Plugins <https://www.lunarvim.org/docs/configuration/plugins/user-plugins>
lvim.plugins = {
    {
        "folke/trouble.nvim",
        cmd = "TroubleToggle",
    },
    { "tpope/vim-surround" },
    { "nvim-lua/plenary.nvim" },
    { "kevinhwang91/nvim-bqf" },
    { "nvim-tree/nvim-web-devicons" },
    {
        "ibhagwan/fzf-lua",
        config = function()
            require("nvim-web-devicons").setup()
        end
    },
    { "mg979/vim-visual-multi" },
    {
        "phaazon/hop.nvim",
        event = "BufRead",
        branch = 'v2',
        config = function()
            require("hop").setup()
            vim.api.nvim_set_keymap("n", "S", ":HopChar2<cr>", { silent = true })
            vim.api.nvim_set_keymap("n", "s", ":HopWord<cr>", { silent = true })
        end,
    },
    {
        "nacro90/numb.nvim",
        event = "BufRead",
        config = function()
            require("numb").setup {
                show_numbers = true,    -- Enable 'number' for the window while peeking
                show_cursorline = true, -- Enable 'cursorline' for the window while peeking
            }
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = "VeryLazy",
        dependecies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            handlers = {}
        },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "clangd",
                "clang-format",
                "codelldb",
            }
        }
    },
    {
        -- "AlexvZyl/nordic.nvim",
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        "simrat39/rust-tools.nvim",
        config = function()
            require("rust-tools").setup {
                tools = {
                    executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
                    reload_workspace_from_cargo_toml = true,
                    runnables = {
                        use_telescope = true,
                    },
                    inlay_hints = {
                        auto = true,
                        only_current_line = false,
                        show_parameter_hints = false,
                        parameter_hints_prefix = "<-",
                        other_hints_prefix = "=>",
                        max_len_align = false,
                        max_len_align_padding = 1,
                        right_align = false,
                        right_align_padding = 7,
                        highlight = "Comment",
                    },
                    hover_actions = {
                        border = "rounded",
                    },
                    on_initialized = function()
                        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
                            pattern = { "*.rs" },
                            callback = function()
                                local _, _ = pcall(vim.lsp.codelens.refresh)
                            end,
                        })
                    end,
                },
                dap = {
                    -- adapter= codelldb_adapter,
                    adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
                },
                server = {
                    on_attach = function(client, bufnr)
                        require("lvim.lsp").common_on_attach(client, bufnr)
                        local rt = require "rust-tools"
                        vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
                    end,

                    capabilities = require("lvim.lsp").common_capabilities(),
                    settings = {
                        ["rust-analyzer"] = {
                            lens = {
                                enable = true,
                            },
                            checkOnSave = {
                                enable = true,
                                command = "clippy",
                            },
                        },
                    },
                },
            }
        end
    }
    -- {
    --     "catppuccin/nvim",
    --     name = "catppuccin"
    -- }
    -- {
    --     "folke/todo-comments.nvim",
    --     event = "BufRead",
    --     config = function()
    --         require("todo-comments").setup()
    --     end,
    -- }
}

---- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })

-- don't really know why this does not work
-- if vim.api.nvim_win_get_option(0, "diff") then
--     vim.cmd("highlight! link DiffText MatchParen")
-- end
