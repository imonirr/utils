local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

-- java spring boot run stuff

M.go_to_project_root = function()
  local pom_dir = vim.fn.fnamemodify(vim.fn.findfile("pom.xml", ".;"), ":h")
  if pom_dir ~= "" then
    vim.cmd("cd " .. pom_dir)
  else
    print("pom.xml not found in any parent directory")
  end
end

M.get_spring_boot_runner = function(profile, debug)
  local debug_param = ""
  if debug then
    debug_param =
      ' -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005" '
  end

  local profile_param = ""
  if profile then
    profile_param = " -Dspring-boot.run.profiles=" .. profile .. " "
  end

  return "mvn clean compile && watchexec -w ./src --restart -e java -v 'mvn spring-boot:run'  "
    .. profile_param
    .. debug_param
end

M.run_spring_boot = function(debug)
  M.go_to_project_root()
  vim.cmd("term " .. M.get_spring_boot_runner("local", debug))
end

-- JAVA springboot TEST stuff

-- Find nodes by type
M.find_node_by_type = function(expr, type_name)
  while expr do
    if expr:type() == type_name then
      break
    end
    expr = expr:parent()
  end
  return expr
end

-- Find child nodes by type
M.find_child_by_type = function(expr, type_name)
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
M.get_current_method_name = function()
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return nil
  end

  local expr = M.find_node_by_type(current_node, "method_declaration")
  if not expr then
    return nil
  end

  local child = M.find_child_by_type(expr, "identifier")
  if not child then
    return nil
  end
  return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Class Name
M.get_current_class_name = function()
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return nil
  end

  local class_declaration = M.find_node_by_type(current_node, "class_declaration")
  if not class_declaration then
    return nil
  end

  local child = M.find_child_by_type(class_declaration, "identifier")
  if not child then
    return nil
  end
  return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Package Name
M.get_current_package_name = function()
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return nil
  end

  local program_expr = M.find_node_by_type(current_node, "program")
  if not program_expr then
    return nil
  end
  local package_expr = M.find_child_by_type(program_expr, "package_declaration")
  if not package_expr then
    return nil
  end

  local child = M.find_child_by_type(package_expr, "scoped_identifier")
  if not child then
    return nil
  end
  return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Full Class Name
M.get_current_full_class_name = function()
  local package = M.get_current_package_name()
  local class = M.get_current_class_name()
  return package .. "." .. class
end

-- Get Current Full Method Name with delimiter or default '.'
M.get_current_full_method_name = function(delimiter)
  delimiter = delimiter or "."
  local full_class_name = M.get_current_full_class_name()
  local method_name = M.get_current_method_name()
  return full_class_name .. delimiter .. method_name
end

-- run debug
M.get_test_runner = function(test_name, debug)
  if debug then
    return 'mvn test -Dmaven.surefire.debug -Dtest="' .. test_name .. '"'
  end
  return 'mvn test -Dtest="' .. test_name .. '"'
end

M.run_java_test_method = function(debug)
  local method_name = M.get_current_full_method_name("\\#")
  vim.cmd("term " .. M.get_test_runner(method_name, debug))
end

M.run_java_test_class = function(debug)
  local class_name = M.get_current_full_class_name()
  vim.cmd("term " .. M.get_test_runner(class_name, debug))
end

return M
