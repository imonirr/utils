-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local ts_utils = require("nvim-treesitter.ts_utils")

-- map semicolon to command prompt with colon
vim.keymap.set("n", ";", ":", { desc = "semicolon opens command prompt" })

-- delete save keymap
vim.keymap.del("i", "<c-s>")
vim.keymap.del("x", "<c-s>")
vim.keymap.del("n", "<c-s>")
vim.keymap.del("s", "<c-s>")

-- navigating panes
vim.keymap.set("n", "<C-h", ":wincmd k<CR>")
vim.keymap.set("n", "<C-j", ":wincmd j<CR>")
vim.keymap.set("n", "<C-l", ":wincmd l<CR>")
vim.keymap.set("n", "<C-k", ":wincmd k<CR>")

-- java spring boot run stuff
local function get_spring_boot_runner(profile, debug)
  local debug_param = ""
  if debug then
    debug_param =
      ' -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005" '
  end

  local profile_param = ""
  if profile then
    profile_param = " -Dspring-boot.run.profiles=" .. profile .. " "
  end

  return "mvn clean compile && mvn spring-boot:run " .. profile_param .. debug_param
end

local function run_spring_boot(debug)
  vim.cmd("term " .. get_spring_boot_runner("local", debug))
end

vim.keymap.set("n", "<leader>jr", function()
  run_spring_boot()
end, { desc = "Run:SpringBoot" })

vim.keymap.set("n", "<leader>jd", function()
  run_spring_boot(true)
end, { desc = "DEBUG:SpringBoot" })

-- JAVA springboot TEST stuff

-- Find nodes by type
local function find_node_by_type(expr, type_name)
  while expr do
    if expr:type() == type_name then
      break
    end
    expr = expr:parent()
  end
  return expr
end

-- Find child nodes by type
local function find_child_by_type(expr, type_name)
  local id = 0
  local expr_child = expr:child(id)
  while expr_child do
    if expr_child:type() == type_name then
      break
    end
    id = id + 1
    expr_child = expr:child(id)
  end

  return expr_child
end

-- Get Current Method Name
local function get_current_method_name()
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return nil
  end

  local expr = find_node_by_type(current_node, "method_declaration")
  if not expr then
    return nil
  end

  local child = find_child_by_type(expr, "identifier")
  if not child then
    return nil
  end
  return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Class Name
local function get_current_class_name()
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return nil
  end

  local class_declaration = find_node_by_type(current_node, "class_declaration")
  if not class_declaration then
    return nil
  end

  local child = find_child_by_type(class_declaration, "identifier")
  if not child then
    return nil
  end
  return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Package Name
local function get_current_package_name()
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return nil
  end

  local program_expr = find_node_by_type(current_node, "program")
  if not program_expr then
    return nil
  end
  local package_expr = find_child_by_type(program_expr, "package_declaration")
  if not package_expr then
    return nil
  end

  local child = find_child_by_type(package_expr, "scoped_identifier")
  if not child then
    return nil
  end
  return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Full Class Name
local function get_current_full_class_name()
  local package = get_current_package_name()
  local class = get_current_class_name()
  return package .. "." .. class
end

-- Get Current Full Method Name with delimiter or default '.'
local function get_current_full_method_name(delimiter)
  delimiter = delimiter or "."
  local full_class_name = get_current_full_class_name()
  local method_name = get_current_method_name()
  return full_class_name .. delimiter .. method_name
end

-- run debug
local function get_test_runner(test_name, debug)
  if debug then
    return 'mvn test -Dmaven.surefire.debug -Dtest="' .. test_name .. '"'
  end
  return 'mvn test -Dtest="' .. test_name .. '"'
end

local function run_java_test_method(debug)
  local method_name = get_current_full_method_name("\\#")
  vim.cmd("term " .. get_test_runner(method_name, debug))
end

local function run_java_test_class(debug)
  local class_name = get_current_full_class_name()
  vim.cmd("term " .. get_test_runner(class_name, debug))
end

vim.keymap.set("n", "<leader>jtm", function()
  run_java_test_method()
end, { desc = "TestMethod:SpringBoot" })

vim.keymap.set("n", "<leader>jtM", function()
  run_java_test_method(true)
end, { desc = "DebugTestMethod:SpringBoot" })

vim.keymap.set("n", "<leader>jtc", function()
  run_java_test_class()
end, { desc = "TestClass:SpringBoot" })

vim.keymap.set("n", "<leader>jtC", function()
  run_java_test_class(true)
end, { desc = "DebugTestClass:SpringBoot" })
