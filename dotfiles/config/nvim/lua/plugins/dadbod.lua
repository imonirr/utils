return {
  "kristijanhusak/vim-dadbod-ui",
  init = function()
    vim.g.dbs = {
      ["tca-LOCAL"] = os.getenv("TCA_LOCAL_DB_URL"),
      ["tca-QA"] = os.getenv("TCA_QA_DB_URL"),
      ["tca-DEV"] = os.getenv("TCA_DEV_DB_URL"),
      ["tca-TEST"] = os.getenv("TCA_TEST_DB_URL"),
      ["tca-PROD"] = os.getenv("TCA_PROD_DB_URL"),
    }

    vim.g.db_ui_save_location = "~/work/dadbod_queries"

    vim.g.db_ui_execute_on_save = false

    vim.g.db_ui_table_helpers = {
      postgres = {
        Count = 'SELECT count(*) FROM "{schema}"."{table}"',
        DeleteTable = 'DROP TABLE "{schema}"."{table}" CASCADE',
        List = 'SELECT * from "{schema}"."{table}" LIMIT 10',
      },
    }
  end,
}
