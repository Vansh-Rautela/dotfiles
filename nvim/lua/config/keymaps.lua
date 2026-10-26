-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>zn", function()
  local id = os.date("%Y%m%d%H%M")
  vim.cmd("edit ~/notes/zettel/" .. id .. ".md")
end, { desc = "New zettel" })
vim.keymap.set("n", "<leader>zi", function()
  vim.cmd("edit ~/notes/inbox/inbox.md")
end, { desc = "Open inbox" })

vim.keymap.set("n", "<leader>fn", function()
  require("lazyvim.util").pick("files", {
    cwd = "~/notes",
  })
end, { desc = "Find notes" })

vim.keymap.set("n", "<leader>sn", function()
  require("lazyvim.util").pick("live_grep", {
    cwd = "~/notes",
  })
end, { desc = "Search notes text" })
-- Robust C++ Compile & Run

local function run_cpp(opts)
  opts = opts or {}

  -- Save file
  vim.cmd("write")

  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local name = vim.fn.expand("%:t:r")

  -- Build command
  local compile_cmd = string.format(
    'g++ -std=gnu++20 -O2 -Wall -Wextra -Wshadow -DLOCAL "%s" -o "%s"',
    file,
    name
  )

  local run_cmd = string.format('./"%s"', name)

  if opts.input then
    run_cmd = run_cmd .. " < input.txt"
  end

  local full_cmd = string.format(
    'cd "%s" && %s && %s',
    dir,
    compile_cmd,
    run_cmd
  )

  -- Open terminal split and execute
  vim.cmd("botright split")
  vim.cmd("resize 15")
  vim.cmd("terminal " .. full_cmd)

  -- Go to insert mode automatically
  vim.cmd("startinsert")
end

-- Compile + Run
vim.keymap.set("n", "<leader>r", function()
  run_cpp()
end, { desc = "C++ Compile & Run" })

-- Compile + Run with input.txt
vim.keymap.set("n", "<leader>ri", function()
  run_cpp({ input = true })
end, { desc = "C++ Compile & Run (input.txt)" })

-- Run already compiled binary
vim.keymap.set("n", "<leader>rr", function()
  local dir = vim.fn.expand("%:p:h")
  local name = vim.fn.expand("%:t:r")

  local cmd = string.format('cd "%s" && ./"%s"', dir, name)

  vim.cmd("botright split")
  vim.cmd("resize 15")
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end, { desc = "Run compiled binary" })


vim.keymap.set("n", "<leader>pi", function()
  local img_dir = vim.fn.expand("%:p:h") .. "/assets"
  vim.fn.mkdir(img_dir, "p")

  local filename = os.date("%Y%m%d%H%M%S") .. ".png"
  local filepath = img_dir .. "/" .. filename

  vim.fn.system("wl-paste --type image/png > " .. filepath)

  local rel_path = "assets/" .. filename
  vim.api.nvim_put({ "![](" .. rel_path .. ")" }, "l", true, true)
end, { desc = "Paste image from clipboard" })


-- Markdown Preview Toggle
vim.keymap.set("n", "<leader>mp", function()
  if vim.bo.filetype == "markdown" then
    vim.cmd("MarkdownPreviewToggle")
  else
    print("Not a markdown file")
  end
end, { desc = "Toggle Markdown Preview" })


vim.keymap.set("n", "<leader>cp", function()
  local name = vim.fn.input("Problem name: ")
  if name == "" then return end

  local slug = name:gsub("%s+", "-"):lower()
  local dir = vim.fn.expand("~/notes/problems/")
  vim.fn.mkdir(dir, "p")

  local filepath = dir .. slug .. ".md"

  vim.cmd("edit " .. filepath)

  if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
    vim.cmd("0r ~/notes/templates/cp_problem.md")
  end

  vim.api.nvim_win_set_cursor(0, { 1, 10 })
end, { desc = "Create CP problem note" })

vim.keymap.set("n", "<leader>np", function()
  local template = vim.fn.expand("~/cp/templates/cp_problem.md")

  if vim.fn.filereadable(template) == 1 then
    vim.cmd("0r " .. template)
  else
    print("Template not found: " .. template)
  end
end, { desc = "Insert CP problem template" })

vim.keymap.set("n", "<leader>vc", function()
  vim.cmd("cd ~/.config/nvim")
  vim.cmd("edit init.lua")
end, { desc = "Open nvim config" })
vim.keymap.set("n", "<leader>pi", function()
  require("snacks").image()
end, { desc = "Preview image" })


vim.keymap.set("n", "<leader>tt", function()
  vim.cmd("0read ~/cp/templates/template.cpp")
end, { desc = "Insert C++ CP template" })

vim.keymap.set("n", "<leader>jc", "<cmd>MoltenEvaluateCell<CR>", {
  desc = "Run Jupyter Cell",
})

vim.keymap.set("n", "<leader>jl", "<cmd>MoltenEvaluateLine<CR>", {
  desc = "Run Line",
})

vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.files({ cwd = vim.fn.input("Project: ", vim.fn.getcwd(), "dir") })
end, { desc = "Open project" })


vim.keymap.set("n", "<leader>tt", function()
  Snacks.terminal(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal (file dir)" })

vim.keymap.set("n", "<leader>cd", function()
  vim.cmd("cd %:p:h")
end, { desc = "CD to current file" })

-- C++ / DSA helpers (added by nvim-cpp-dsa-setup)
require("config.cpp_dsa").setup()
