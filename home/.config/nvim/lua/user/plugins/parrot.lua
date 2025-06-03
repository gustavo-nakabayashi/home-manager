local M = {
  "frankroeder/parrot.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  commit = "bc987482006f25cbdd269db0d8c4489e15d8c25f",
  opts = {}
}

function M.config()
      require("parrot").setup {
      providers = {
        anthropic = {
          api_key = os.getenv "ANTHROPIC_API_KEY",
        },
        -- gemini = {
        --   api_key = os.getenv "GEMINI_API_KEY",
        -- },
        -- groq = {
        --   api_key = os.getenv "GROQ_API_KEY",
        -- },
        -- mistral = {
        --   api_key = os.getenv "MISTRAL_API_KEY",
        -- },
        -- pplx = {
        --   api_key = os.getenv "PERPLEXITY_API_KEY",
        -- },
        -- -- provide an empty list to make provider available (no API key required)
        -- ollama = {},
        -- openai = {
        --   api_key = os.getenv "OPENAI_API_KEY",
        -- },
        -- github = {
        --   api_key = os.getenv "GITHUB_TOKEN",
        -- },
        -- nvidia = {
        --   api_key = os.getenv "NVIDIA_API_KEY",
        -- },
        -- xai = {
        --   api_key = os.getenv "XAI_API_KEY",
        -- },
      },
        hooks = {
        AnalyseMultiContext = function(prt, params)
          local template = [[
          I have the following code from {{filename}} and other realted files:

          ```{{filetype}}
          {{multifilecontent}}
          ```

          Please explain the code you get and the files you analyzed.
          ]]
          local model_obj = prt.get_model "command"
          prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
        end,
      }
    }
end

return M

