if vim.g.vscode then return {} end

-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  { import = "astrocommunity.pack.lua" },

  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.basedpyright" },
  { import = "astrocommunity.pack.python.black" },
  { import = "astrocommunity.pack.python.isort" },

  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.cpp" },
  {
    "Civitasv/cmake-tools.nvim",
    cmd = { "CMakeSelectCwd" },
  },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.java" },
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      settings = {
        -- java = {
        --   configuration = {
        --     runtimes = {
        --       {
        --         name = "JavaSE-11",
        --         path = "/usr/lib/jvm/java-11-openjdk/",
        --         default = true,
        --       },
        --     },
        --   },
        -- },
        format = {
          enabled = true,
          settings = {
            url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
            profile = "GoogleStyle",
          },
        },
      },
    },
  },
  { import = "astrocommunity.pack.spring-boot" },
  -- { import = "astrocommunity.pack.cs" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.xml" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.markdown" },

  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.utility.noice-nvim" },
}
