return {
  "bassamsdata/namu.nvim",
  cmd = "Namu",
  event = "User AstroFile",
  opts = {
    namu_symbols = {
      options = {
        -- in namu_symbols.options
        movement = {
          delete_word = { "<C-w>" }, -- delete word mapping
          clear_line = { "<C-u>" }, -- clear line mapping
        },
      },
    },
  },
  specs = {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<M-f>"] = { function() vim.cmd.Namu "symbols" end, desc = "Search symbols" },
        },
      },
    },
  },
}

-- Available Symbol Types:
-- ----------------------------------------
--
--   co - Constants and literal values
--     Matches: Constant, Boolean, Number, String
--
--   cl - Classes, interfaces and structures
--     Matches: Class, Interface, Struct
--
--   mo - Modules and packages
--     Matches: Module, Package, Namespace
--
--   fn - Functions, methods and constructors
--     Matches: Function, Constructor
--
--   ob - Objects and class instances
--     Matches: Object, Class, Instance
--
--   ar - Arrays, lists and sequences
--     Matches: Array, List, Sequence
--
--   va - Variables and parameters
--     Matches: Variable, Parameter, TypeParameter
--
--   fi - Object fields and properties
--     Matches: Field, Property, EnumMember
--
--   me - Methods
--     Matches: Method, Accessor
--
