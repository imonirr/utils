vim.g.dbs = {
  ["tca-LOCAL"] = os.getenv("TCA_LOCAL_DB_URL"),
  ["tca-QA"] = os.getenv("TCA_QA_DB_URL"),
  ["tca-DEV"] = os.getenv("TCA_DEV_DB_URL"),
  ["tca-TEST"] = os.getenv("TCA_TEST_DB_URL"),
  ["tca-PROD"] = os.getenv("TCA_PROD_DB_URL"),
}

vim.g.db_ui_save_location = "~/work/db_ui_queries"

vim.g.db_ui_table_helpers = {
  postgres = {
    Count = 'select count(*) from "{schema}"."{table}"',
  },
}

-- vim.g:db_ui_table_helpers = {
--    'postgresql': {
--      'Count': 'select count(*) from "{table}"'
--    }
--  }
--
