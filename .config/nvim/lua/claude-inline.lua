local M = {}

local processing = false

local function get_visual_selection()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return start_line, end_line, lines
end

local function build_prompt(filetype, buf_lines, start_line, end_line, selected_lines, instruction)
  local full_file = table.concat(buf_lines, "\n")
  local selected_text = table.concat(selected_lines, "\n")

  return table.concat({
    "You are an inline code editor. You will receive a file and a selected region",
    "within it, along with an instruction.",
    "",
    "Return ONLY the replacement text for the selected region. Do not include any",
    "explanation, markdown formatting, or code fences.",
    "",
    "Filetype: " .. filetype,
    "",
    "Full file:",
    full_file,
    "",
    string.format("Selected region (lines %d-%d):", start_line, end_line),
    selected_text,
    "",
    "Instruction: " .. instruction,
  }, "\n")
end

local function strip_code_fences(text)
  -- Remove leading ```lang and trailing ```
  text = text:gsub("^%s*```[%w]*%s*\n", "")
  text = text:gsub("\n%s*```%s*$", "")
  -- Also handle case where entire response is wrapped
  text = text:gsub("^%s*```[%w]*%s*\n(.+)\n%s*```%s*$", "%1")
  return text
end

local function open_input_window(on_submit, on_cancel)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })

  local width = 60
  local row = math.floor((vim.o.lines - 3) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Claude Inline Edit ",
    title_pos = "center",
  })

  vim.cmd("startinsert")

  vim.keymap.set("i", "<CR>", function()
    local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
    on_submit(line)
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("i", "<Esc>", function()
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
    if on_cancel then on_cancel() end
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
    if on_cancel then on_cancel() end
  end, { buffer = buf, noremap = true, silent = true })
end

local function claude_inline()
  if processing then
    vim.notify("Claude inline edit already in progress", vim.log.levels.WARN)
    return
  end

  local target_buf = vim.api.nvim_get_current_buf()
  local start_line, end_line, selected_lines = get_visual_selection()

  if #selected_lines == 0 then
    vim.notify("No selection", vim.log.levels.WARN)
    return
  end

  local filetype = vim.bo[target_buf].filetype
  local buf_lines = vim.api.nvim_buf_get_lines(target_buf, 0, -1, false)

  open_input_window(function(instruction)
    if instruction == "" then return end

    processing = true

    local prompt = build_prompt(filetype, buf_lines, start_line, end_line, selected_lines, instruction)

    -- Show "thinking..." indicator
    local ns = vim.api.nvim_create_namespace("claude_inline")
    local extmark_id = vim.api.nvim_buf_set_extmark(target_buf, ns, start_line - 1, 0, {
      virt_text = { { " thinking...", "Comment" } },
      virt_text_pos = "eol",
    })

    local stdout_chunks = {}

    local job_id = vim.fn.jobstart({ "claude", "-p" }, {
      stdout_buffered = true,
      on_stdout = function(_, data, _)
        if data then
          for _, chunk in ipairs(data) do
            table.insert(stdout_chunks, chunk)
          end
        end
      end,
      on_exit = function(_, exit_code, _)
        vim.schedule(function()
          processing = false

          -- Clear indicator
          if vim.api.nvim_buf_is_valid(target_buf) then
            vim.api.nvim_buf_del_extmark(target_buf, ns, extmark_id)
          end

          if exit_code ~= 0 then
            vim.notify("Claude exited with code " .. exit_code, vim.log.levels.ERROR)
            return
          end

          local response = table.concat(stdout_chunks, "\n")
          -- Remove trailing empty string from jobstart output
          response = response:gsub("\n$", "")

          if response == "" then
            vim.notify("Claude returned an empty response", vim.log.levels.WARN)
            return
          end

          response = strip_code_fences(response)

          if not vim.api.nvim_buf_is_valid(target_buf) then
            vim.notify("Buffer no longer valid", vim.log.levels.WARN)
            return
          end

          local new_lines = vim.split(response, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(target_buf, start_line - 1, end_line, false, new_lines)
        end)
      end,
    })

    if job_id <= 0 then
      processing = false
      vim.api.nvim_buf_del_extmark(target_buf, ns, extmark_id)
      vim.notify("Failed to start claude CLI", vim.log.levels.ERROR)
      return
    end

    vim.fn.chansend(job_id, prompt)
    vim.fn.chanclose(job_id, "stdin")
  end)
end

vim.keymap.set("v", "<leader>ai", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  vim.defer_fn(claude_inline, 50)
end, { noremap = true, silent = true, desc = "Claude inline edit" })

return M
