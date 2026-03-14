---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-treesitter-textobjects").setup {
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
    }

    local select = require "nvim-treesitter-textobjects.select"
    local move = require "nvim-treesitter-textobjects.move"
    local swap = require "nvim-treesitter-textobjects.swap"

    local function map_select(lhs, query, desc, query_group)
      vim.keymap.set(
        { "x", "o" },
        lhs,
        function() select.select_textobject(query, query_group or "textobjects") end,
        { desc = desc }
      )
    end

    local function map_move(modes, lhs, method, query, desc, query_group)
      vim.keymap.set(modes, lhs, function() move[method](query, query_group or "textobjects") end, { desc = desc })
    end

    local function map_swap(lhs, method, query, desc, query_group)
      vim.keymap.set("n", lhs, function() swap[method](query, query_group or "textobjects") end, { desc = desc })
    end

    map_select("ak", "@block.outer", "around block")
    map_select("ik", "@block.inner", "inside block")
    map_select("af", "@function.outer", "around function")
    map_select("if", "@function.inner", "inside function")
    map_select("aa", "@parameter.outer", "around argument")
    map_select("ia", "@parameter.inner", "inside argument")
    map_select("as", "@call.outer", "around callsite")
    map_select("is", "@call.inner", "inside callsite")
    map_select("ar", "@return.outer", "around return")
    map_select("ir", "@return.inner", "inside return")
    map_select("av", "@conditional.outer", "around conditional")
    map_select("iv", "@conditional.inner", "inside conditional")
    map_select("al", "@loop.outer", "around loop")
    map_select("il", "@loop.inner", "inside loop")
    map_select("az", "@class.outer", "around class")
    map_select("iz", "@class.inner", "inside class")
    map_select("an", "@assignment.outer", "around assignment")
    map_select("in", "@assignment.inner", "inside assignment")
    map_select("ah", "@number.inner", "around number")
    map_select("ih", "@number.inner", "inside number")

    map_move({ "n", "x", "o" }, "<M-x>", "goto_next_start", "@block.outer", "Next block start")
    map_move({ "n", "x", "o" }, "<M-N>", "goto_next_start", "@function.outer", "Next function start")
    map_move({ "n", "x", "o" }, "<M-l>", "goto_next_start", "@call.outer", "Next callsite start")
    map_move({ "n", "x", "o" }, "<M-v>", "goto_next_start", "@conditional.outer", "Next conditional start")
    map_move({ "n", "x", "o" }, "<M-g>", "goto_next_start", "@loop.outer", "Next loop start")
    map_move({ "n", "x", "o" }, "<M-z>", "goto_next_start", "@class.outer", "Next class start")
    map_move({ "n", "x", "o" }, "<M-t>", "goto_next_start", "@number.inner", "Next number")
    map_move({ "n", "x", "o" }, "]k", "goto_next_start", "@block.outer", "Next block start")
    map_move({ "n", "x", "o" }, "]f", "goto_next_start", "@function.outer", "Next function start")
    map_move({ "n", "x", "o" }, "]a", "goto_next_start", "@parameter.inner", "Next argument start")
    map_move({ "n", "x", "o" }, "]s", "goto_next_start", "@call.outer", "Next callsite start")
    map_move({ "n", "x", "o" }, "]r", "goto_next_start", "@return.outer", "Next return start")
    map_move({ "n", "x", "o" }, "]v", "goto_next_start", "@conditional.outer", "Next conditional start")
    map_move({ "n", "x", "o" }, "]g", "goto_next_start", "@loop.outer", "Next loop start")
    map_move({ "n", "x", "o" }, "]z", "goto_next_start", "@class.outer", "Next class start")
    map_move({ "n", "x", "o" }, "]n", "goto_next_start", "@assignment.rhs", "Next assignment rhs")
    map_move({ "n", "x", "o" }, "]h", "goto_next_start", "@number.inner", "Next number")
    map_move({ "n", "x", "o" }, "]]", "goto_next_start", "@comment.outer", "Next comment start")

    map_move({ "n", "x", "o" }, "<M-B>", "goto_next_end", "@block.outer", "Next block end")
    map_move({ "n", "x", "o" }, "<M-E>", "goto_next_end", "@function.outer", "Next function end")
    map_move({ "n", "x", "o" }, "<M-.>", "goto_next_end", "@parameter.inner", "Next argument end")
    map_move({ "n", "x", "o" }, "]K", "goto_next_end", "@block.outer", "Next block end")
    map_move({ "n", "x", "o" }, "]F", "goto_next_end", "@function.outer", "Next function end")
    map_move({ "n", "x", "o" }, "]A", "goto_next_end", "@parameter.inner", "Next argument end")
    map_move({ "n", "x", "o" }, "]Z", "goto_next_end", "@class.outer", "Next class end")

    map_move({ "n", "x", "o" }, "<M-X>", "goto_previous_start", "@block.outer", "Previous block start")
    map_move({ "n", "x", "o" }, "<M-P>", "goto_previous_start", "@function.outer", "Previous function start")
    map_move({ "n", "x", "o" }, "<M-b>", "goto_previous_start", "@parameter.inner", "Previous argument start")
    map_move({ "n", "x", "o" }, "<M-h>", "goto_previous_start", "@call.outer", "Previous callsite start")
    map_move({ "n", "x", "o" }, "<M-V>", "goto_previous_start", "@conditional.outer", "Previous conditional start")
    map_move({ "n", "x", "o" }, "<M-G>", "goto_previous_start", "@loop.outer", "Previous loop start")
    map_move({ "n", "x", "o" }, "<M-Z>", "goto_previous_start", "@class.outer", "Previous class start")
    map_move({ "n", "x", "o" }, "<M-T>", "goto_previous_start", "@number.inner", "Previous number")
    map_move({ "n", "x", "o" }, "[k", "goto_previous_start", "@block.outer", "Previous block start")
    map_move({ "n", "x", "o" }, "[f", "goto_previous_start", "@function.outer", "Previous function start")
    map_move({ "n", "x", "o" }, "[a", "goto_previous_start", "@parameter.inner", "Previous argument start")
    map_move({ "n", "x", "o" }, "[s", "goto_previous_start", "@call.outer", "Previous callsite start")
    map_move({ "n", "x", "o" }, "[r", "goto_previous_start", "@return.outer", "Previous return start")
    map_move({ "n", "x", "o" }, "[v", "goto_previous_start", "@conditional.outer", "Previous conditional start")
    map_move({ "n", "x", "o" }, "[g", "goto_previous_start", "@loop.outer", "Previous loop start")
    map_move({ "n", "x", "o" }, "[z", "goto_previous_start", "@class.outer", "Previous class start")
    map_move({ "n", "x", "o" }, "[n", "goto_previous_start", "@assignment.lhs", "Previous assignment lhs")
    map_move({ "n", "x", "o" }, "[h", "goto_previous_start", "@number.inner", "Previous number")
    map_move({ "n", "x", "o" }, "[[", "goto_previous_start", "@comment.outer", "Previous comment start")

    map_move({ "n", "x", "o" }, "<M-,>", "goto_previous_end", "@parameter.inner", "Previous argument end")
    map_move({ "n", "x", "o" }, "[K", "goto_previous_end", "@block.outer", "Previous block end")
    map_move({ "n", "x", "o" }, "[F", "goto_previous_end", "@function.outer", "Previous function end")
    map_move({ "n", "x", "o" }, "[A", "goto_previous_end", "@parameter.inner", "Previous argument end")
    map_move({ "n", "x", "o" }, "[Z", "goto_previous_end", "@class.outer", "Previous class end")

    map_swap(">K", "swap_next", "@block.outer", "Swap next block")
    map_swap(">F", "swap_next", "@function.outer", "Swap next function")
    map_swap(">A", "swap_next", "@parameter.inner", "Swap next argument")
    map_swap("<K", "swap_previous", "@block.outer", "Swap previous block")
    map_swap("<F", "swap_previous", "@function.outer", "Swap previous function")
    map_swap("<A", "swap_previous", "@parameter.inner", "Swap previous argument")
  end,
}
