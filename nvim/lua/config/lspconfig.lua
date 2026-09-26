local lspconfig = require("lspconfig")

lspconfig.groovyls.setup({
  cmd = { "groovy-language-server" }, -- or path to your java -jar setup
  filetypes = { "groovy" },
  settings = {
    groovy = {
      classpath = {
        -- Add specific project library paths if dependencies aren't resolved
      },
    },
  },
})
