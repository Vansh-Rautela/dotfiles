-- C++ / DSA helpers for LazyVim.
-- Loaded from lua/config/keymaps.lua. Does not replace your existing config.

local M = {}

local function current_cpp()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Save the C++ file before compiling.", vim.log.levels.WARN)
    return nil
  end
  if vim.bo.filetype ~= "cpp" and not file:match("%.cc$") and not file:match("%.cxx$") and not file:match("%.cpp$") then
    vim.notify("Current buffer does not look like a C++ source file.", vim.log.levels.WARN)
    return nil
  end
  vim.cmd.write()
  return file
end

local function terminal_run(command, cwd, title)
  vim.cmd("botright 15split")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buflisted = false
  vim.api.nvim_buf_set_name(buf, "cpp://" .. title .. "-" .. os.date("%H%M%S"))
  vim.fn.termopen({ "bash", "-lc", command }, {
    cwd = cwd,
    on_exit = function(_, code)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.notify(title .. (code == 0 and " finished successfully" or (" exited with code " .. code)), code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
        end
      end)
    end,
  })
  vim.cmd.startinsert()
end

local function compile_command(file, output)
  -- g++ is the default for judge compatibility; GNU++20 is a common DSA baseline.
  return "g++ -std=gnu++20 -O2 -pipe -Wall -Wextra -Wshadow "
    .. vim.fn.shellescape(file) .. " -o " .. vim.fn.shellescape(output)
end

function M.compile_run(with_input)
  local file = current_cpp()
  if not file then return end
  local dir = vim.fn.fnamemodify(file, ":h")
  local stem = vim.fn.fnamemodify(file, ":t:r")
  local output = dir .. "/" .. stem
  local cmd = compile_command(file, output)
    .. " && " .. vim.fn.shellescape(output)
  if with_input then
    local input = dir .. "/input.txt"
    if vim.fn.filereadable(input) ~= 1 then
      vim.notify("input.txt not found beside the source file.", vim.log.levels.WARN)
      return
    end
    cmd = compile_command(file, output) .. " && " .. vim.fn.shellescape(output)
      .. " < " .. vim.fn.shellescape(input)
  end
  terminal_run(cmd, dir, with_input and "C++ run with input.txt" or "C++ compile and run")
end

function M.run_binary()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then return end
  local dir = vim.fn.fnamemodify(file, ":h")
  local output = dir .. "/" .. vim.fn.fnamemodify(file, ":t:r")
  if vim.fn.executable(output) ~= 1 then
    vim.notify("Compiled binary not found. Use <leader>r to compile first.", vim.log.levels.WARN)
    return
  end
  terminal_run(vim.fn.shellescape(output), dir, "Run compiled binary")
end

function M.sample_test()
  local file = current_cpp()
  if not file then return end
  local dir = vim.fn.fnamemodify(file, ":h")
  local stem = vim.fn.fnamemodify(file, ":t:r")
  local input = dir .. "/input.txt"
  local expected = dir .. "/expected.txt"
  local output = dir .. "/" .. stem
  if vim.fn.filereadable(input) ~= 1 then
    vim.notify("Create input.txt beside the source file first.", vim.log.levels.WARN)
    return
  end
  local cmd = compile_command(file, output) .. " && "
    .. vim.fn.shellescape(output) .. " < " .. vim.fn.shellescape(input)
    .. " > " .. vim.fn.shellescape(dir .. "/actual.txt")
    .. " && printf '\\n--- Actual output ---\\n' && cat " .. vim.fn.shellescape(dir .. "/actual.txt")
  if vim.fn.filereadable(expected) == 1 then
    cmd = cmd .. " && printf '\\n--- Diff vs expected.txt (empty means match) ---\\n' && diff -u "
      .. vim.fn.shellescape(expected) .. " " .. vim.fn.shellescape(dir .. "/actual.txt")
      .. "; status=$?; if [ $status -eq 0 ]; then echo 'PASS'; elif [ $status -eq 1 ]; then echo 'FAIL'; else exit $status; fi"
  else
    cmd = cmd .. " && echo '\\nNo expected.txt found; output was saved to actual.txt.'"
  end
  terminal_run(cmd, dir, "C++ sample test")
end

function M.insert_template()
  local template = [[#include <bits/stdc++.h>
using namespace std;

using ll = long long;
using ull = unsigned long long;
using pii = pair<int, int>;
using vi = vector<int>;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    
    return 0;
}
]]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 1 and lines[1] == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, "\n", { plain = true }))
  else
    vim.api.nvim_put(vim.split(template, "\n", { plain = true }), "l", true, true)
  end
  vim.bo.filetype = "cpp"
end

function M.setup()
  local map = vim.keymap.set
  map("n", "<leader>r", function() M.compile_run(false) end, { desc = "C++: Compile and run" })
  map("n", "<leader>ri", function() M.compile_run(true) end, { desc = "C++: Run with input.txt" })
  map("n", "<leader>rr", M.run_binary, { desc = "C++: Run compiled binary" })
  map("n", "<leader>rt", M.sample_test, { desc = "C++: Run sample test and diff" })
  map("n", "<leader>ct", M.insert_template, { desc = "C++: Insert DSA template" })
  map("n", "<leader>cf", function()
    if vim.fn.executable("clang-format") == 1 then
      vim.lsp.buf.format({ async = true, timeout_ms = 3000 })
    else
      vim.notify("clang-format is not installed.", vim.log.levels.WARN)
    end
  end, { desc = "C++: Format buffer" })
end

return M
