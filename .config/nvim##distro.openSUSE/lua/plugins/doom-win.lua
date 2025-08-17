-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "AstroNvim/astrocore",
  optional = true,
  opts = {
    mappings = {
      n = {
        -- Change save to s instead of w
        ["<leader>s"] = { "<cmd>w<CR>", desc = "Save" },

        -- Label for the window menu
        ["<leader>w"] = { desc = "󰖯 Windows" },

        -- Smart-splits navigation
        ["<leader>wh"] = {
          function() require("smart-splits").move_cursor_left() end,
          desc = "Focus Left Window",
        },
        ["<leader>wj"] = {
          function() require("smart-splits").move_cursor_down() end,
          desc = "Focus Lower Window",
        },
        ["<leader>wk"] = {
          function() require("smart-splits").move_cursor_up() end,
          desc = "Focus Upper Window",
        },
        ["<leader>wl"] = {
          function() require("smart-splits").move_cursor_right() end,
          desc = "Focus Right Window",
        },
        -- Smart-splits swaping
        ["<leader>wH"] = {
          function() require("smart-splits").swap_buf_left() end,
          desc = "Move Window Left",
        },
        ["<leader>wJ"] = {
          function() require("smart-splits").swap_buf_down() end,
          desc = "Move Window Down",
        },
        ["<leader>wK"] = {
          function() require("smart-splits").swap_buf_up() end,
          desc = "Move Window Up",
        },
        ["<leader>wL"] = {
          function() require("smart-splits").swap_buf_right() end,
          desc = "Move Window Right",
        },
        -- Smart-splits resizing
        ["<leader>w+"] = {
          function() require("smart-splits").resize_up() end,
          desc = "Increase Height",
        },
        ["<leader>w-"] = {
          function() require("smart-splits").resize_down() end,
          desc = "Decrease Height",
        },
        ["<leader>w<"] = {
          function() require("smart-splits").resize_left() end,
          desc = "Decrease Width",
        },
        ["<leader>w>"] = {
          function() require("smart-splits").resize_right() end,
          desc = "Increase Width",
        },
        -- Splitting windows
        ["<leader>wv"] = { "<cmd>vsplit<CR>", desc = "Vertical Split" },
        ["<leader>ws"] = { "<cmd>split<CR>", desc = "Horizontal Split" },
        ["<leader>wV"] = { "<cmd>vsplit<CR><C-w>l", desc = "Vertical Split (Focus)" },
        ["<leader>wS"] = { "<cmd>split<CR><C-w>j", desc = "Horizontal Split (Focus)" },
        -- Window manegment
        ["<leader>w="] = { "<C-w>=", desc = "Equalize Splits" },
        ["<leader>wc"] = { "<cmd>close<CR>", desc = "Close Current Window" },
        ["<leader>wn"] = {
          function()
            vim.cmd "vsplit"
            vim.cmd "enew"
          end,
          desc = "New Buffer (Vertical)",
        },
        ["<leader>wN"] = {
          function()
            vim.cmd "split"
            vim.cmd "enew"
          end,
          desc = "New Buffer (Horizontal)",
        },
      },
    },
  },
}
