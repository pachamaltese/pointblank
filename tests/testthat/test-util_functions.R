test_that("Utility functions won't fail us", {
  
  # Use two validation step functions to create
  # an agent with two validation steps 
  agent <-
    create_agent(tbl = small_table) %>%
    col_vals_gt(columns = vars(c), value = 5) %>%
    col_vals_lt(columns = vars(d), value = 1000)
  
  is_ptblank_agent(x = agent) %>% expect_true()
  is_ptblank_agent(x = small_table) %>% expect_false()
  
  agent %>% get_tbl_object() %>% expect_is("tbl_df")
  agent %>% get_tbl_object() %>% expect_equivalent(small_table)
  
  agent %>% has_agent_intel() %>% expect_false()
  agent %>% interrogate() %>% has_agent_intel() %>% expect_true()
  
  agent %>% is_agent_empty() %>% expect_false()
  small_table %>% is_agent_empty() %>% expect_false()
  create_agent(tbl = small_table) %>% is_agent_empty() %>% expect_true()
  
  agent %>% interrogate() %>% interrogation_time() %>% expect_is("POSIXct")
  agent %>% interrogate() %>% interrogation_time() %>% length() %>% expect_equal(1)
  agent %>% interrogation_time() %>% expect_equal(NA)
  
  agent %>% number_of_validation_steps() %>% expect_equal(2)
  small_table %>% number_of_validation_steps() %>% expect_equal(NA)

  agent %>% get_assertion_type_at_idx(idx = 1) %>% expect_equal("col_vals_gt")
  agent %>% get_assertion_type_at_idx(idx = 2) %>% expect_equal("col_vals_lt")

  agent %>% get_column_as_sym_at_idx(idx = 1) %>% expect_is("name")
  agent %>% get_column_as_sym_at_idx(idx = 1) %>% as.character() %>% expect_equal("c")
  agent %>% get_column_as_sym_at_idx(idx = 2) %>% expect_is("name")
  agent %>% get_column_as_sym_at_idx(idx = 2) %>% as.character() %>% expect_equal("d")
  
  agent %>% get_values_at_idx(idx = 1) %>% expect_is("numeric")
  agent %>% get_values_at_idx(idx = 1) %>% expect_equal(5)
  agent %>% get_values_at_idx(idx = 2) %>% expect_is("numeric")
  agent %>% get_values_at_idx(idx = 2) %>% expect_equal(1000)
  
  agent %>% get_all_cols() %>% expect_is("character")
  agent %>% get_all_cols() %>%
    expect_equal(c("date_time", "date", "a", "b", "c", "d", "e", "f"))
  
  # Use set-based validation step functions to create
  # an agent with two validation steps 
  agent <-
    create_agent(tbl = small_table) %>%
    col_vals_in_set(columns = vars(e), set = c(TRUE, FALSE)) %>%
    col_vals_not_in_set(columns = vars(f), set = c("medium", "floor"))
  
  agent %>% get_values_at_idx(idx = 1) %>% expect_is("logical")
  agent %>% get_values_at_idx(idx = 1) %>% expect_equal(c(TRUE, FALSE))
  agent %>% get_values_at_idx(idx = 2) %>% expect_is("character")
  agent %>% get_values_at_idx(idx = 2) %>% expect_equal(c("medium", "floor"))
  
  # Use the `col_vals_regex()` validation step
  # function to create an agent with one validation step 
  agent <-
    create_agent(tbl = small_table) %>%
    col_vals_regex(columns = vars(b), regex = "[0-9]-[a-z]*?-[0-9]*?")
  
  agent %>% get_values_at_idx(idx = 1) %>% expect_is("character")
  agent %>% get_values_at_idx(idx = 1) %>% expect_equal("[0-9]-[a-z]*?-[0-9]*?")
  
  # Use range-based validation step functions to create
  # an agent with two validation steps 
  agent <-
    create_agent(tbl = small_table) %>%
    col_vals_between(columns = vars(c), left = 2, right = 5, na_pass = TRUE) %>%
    col_vals_not_between(columns = vars(c), left = 2, right = 5, na_pass = FALSE)
  
  agent %>% get_column_na_pass_at_idx(idx = 1) %>% expect_is("logical")
  agent %>% get_column_na_pass_at_idx(idx = 1) %>% expect_equal(TRUE)
  agent %>% get_column_na_pass_at_idx(idx = 2) %>% expect_is("logical")
  agent %>% get_column_na_pass_at_idx(idx = 2) %>% expect_equal(FALSE)
  
  # Expect that the `create_col_schema_from_names_types()` function generates
  # named list object from a character vector and an unnamed list
  col_names <- names(small_table)
  col_types <- unname(lapply(small_table, class))
  
  cs <- create_col_schema_from_names_types(names = col_names, types = col_types)
  
  expect_is(cs, "list")
  expect_equal(names(cs), col_names)
  expect_equal(unname(cs), col_types)
  expect_equal(length(cs), length(col_names), length(col_types))
  
  # Expect that the `normalize_step_id()` function will make suitable
  # transformations of `step_id` based on the number of columns
  agent_0 <- create_agent(tbl = small_table)
  agent_1 <- create_agent(tbl = small_table) %>% col_exists(vars(a))
  agent_3 <- create_agent(tbl = small_table) %>% col_exists(vars(a, b, c))
  columns <- c("a", "b", "c")

  # Expect generated indices (with leading zeros) to be returned if `step_id`
  # is NULL (the number of  `columns` determines with number of steps, and
  # we're starting with an agent that has no validation steps)
  normalize_step_id(step_id = NULL, columns = columns[1], agent_0) %>% 
    expect_equal("0001")
  normalize_step_id(step_id = NULL, columns = columns[1:2], agent_0) %>% 
    expect_equal(c("0001", "0002"))
  normalize_step_id(step_id = NULL, columns = columns, agent_0) %>% 
    expect_equal(c("0001", "0002", "0003"))
  
  # Make similar expectations but use an agent that has a single validation
  # step as a starting point
  normalize_step_id(step_id = NULL, columns = columns[1], agent_1) %>% 
    expect_equal("0002")
  normalize_step_id(step_id = NULL, columns = columns[1:2], agent_1) %>% 
    expect_equal(c("0002", "0003"))
  normalize_step_id(step_id = NULL, columns = columns, agent_1) %>% 
    expect_equal(c("0002", "0003", "0004"))
  
  # Make similar expectations but use an agent that has three validation
  # step as a starting point
  normalize_step_id(step_id = NULL, columns = columns[1], agent_3) %>% 
    expect_equal("0004")
  normalize_step_id(step_id = NULL, columns = columns[1:2], agent_3) %>% 
    expect_equal(c("0004", "0005"))
  normalize_step_id(step_id = NULL, columns = columns, agent_3) %>% 
    expect_equal(c("0004", "0005", "0006"))
  
  # Expect a one-element `step_id` to be returned as-is for
  # the case of a single column
  normalize_step_id(step_id = "single", columns = columns[1], agent_0) %>%
    expect_equal("single")
  
  # Don't expect a warning for the above
  expect_warning(
    regexp = NA,
    normalize_step_id(step_id = "single", columns = columns[1], agent_0)
  )
  
  # Expect a one-element `step_id` to be returned as a one-
  # element vector (first base name) in the case of a single column
  suppressWarnings(
    normalize_step_id(step_id = c("one", "two"), columns = columns[1], agent_0) %>%
      expect_equal("one")
  )
  
  # Expect a warning to be emitted for the previous statement
  expect_warning(normalize_step_id(step_id = c("one", "two"), columns = columns[1], agent_0))
  
  # Expect a two-element `step_id` to be returned as a three-
  # element vector (first base name) in the case of three columns
  # (`step_id` input not `1` or length of `columns`)
  suppressWarnings(
    normalize_step_id(step_id = c("one", "two"), columns = columns, agent_0) %>%
      expect_equal(c("one.0001", "one.0002", "one.0003"))
  )
  
  # Expect a warning to be emitted for the previous statement
  expect_warning(normalize_step_id(step_id = c("one", "two"), columns = columns, agent_0))
  
  # Expect a one-element `step_id` to be returned as a three-
  # element vector (base name + indices) in the case of three columns
  normalize_step_id(step_id = "single", columns = columns, agent_0) %>%
    expect_equal(c("single.0001", "single.0002", "single.0003"))
  
  # Don't expect a warning for the above
  expect_warning(
    regexp = NA,
    normalize_step_id(step_id = "single", columns = columns, agent_0)
  )
  
  # Expect a two-element `step_id` to be returned as a three-
  # element vector (first base name + indices) in the case of three columns
  suppressWarnings(
    normalize_step_id(step_id = c("one", "two"), columns = columns, agent_0) %>%
      expect_equal(c("one.0001", "one.0002", "one.0003"))
  )
  
  # Expect a warning to be emitted for the previous statement
  expect_warning(normalize_step_id(step_id = c("one", "two"), columns = columns, agent_0))
  
  # Expect a three-element `step_id` to be returned as the same three-
  # element vector in the case of three columns
  normalize_step_id(step_id = c("one", "two", "three"), columns = columns, agent_0) %>%
    expect_equal(c("one", "two", "three"))
  
  # Don't expect a warning for the above
  expect_warning(
    regexp = NA,
    normalize_step_id(step_id = c("one", "two", "three"), columns = columns, agent_0)
  )
  
  # Expect a three-element `step_id` as numeric values to be returned as
  # a character based, three-element vector in the case of three columns
  normalize_step_id(step_id = c(1.0, 2.0, 3.0), columns = columns, agent_0) %>%
    expect_equal(c("1", "2", "3"))
  
  # Expect a three-element `step_id` to be returned as a corrected three-
  # element vector (first base name + indices) in the case of some duplicated
  # `step_id` elements (for three columns)
  suppressWarnings(
    normalize_step_id(step_id = c("one", "two", "one"), columns = columns, agent_0) %>%
      expect_equal(c("one.0001", "one.0002", "one.0003"))
  )
  
  # Expect a warning to be emitted for the previous statement
  expect_warning(normalize_step_id(step_id = c("one", "two", "one"), columns = columns, agent_0))
  
  # Expect that the `check_step_id_duplicates()` function will generate
  # an error if a `step_id` has been recorded in previous validation steps
  
  
  agent_0 <- create_agent(tbl = small_table)
  agent_1 <- create_agent(tbl = small_table) %>% col_exists(vars(a))
  agent_3 <- create_agent(tbl = small_table) %>% col_exists(vars(a, b, c))
  
  # There should be no duplicates (and no errors) when starting with
  # an agent that has no validation steps
  expect_error(
    regexp = NA,
    check_step_id_duplicates(step_id = "1", agent_0)
  )
  expect_error(
    regexp = NA,
    check_step_id_duplicates(step_id = c("one", "two", "three"), agent_0)
  )
  
  # Expect an error if re-using a past `step_id`
  expect_error(
    check_step_id_duplicates(step_id = "0001", agent_1)
  )
  expect_error(
    create_agent(tbl = small_table) %>%
      col_exists(vars(a), step_id = "one") %>%
      col_exists(vars(b), step_id = "one")
  )
  
  # Expect no errors if not providing any `step_id` values
  expect_error(
    regexp = NA,
    create_agent(tbl = small_table) %>%
      col_exists(vars(a)) %>%
      col_exists(vars(b)) %>%
      col_is_character(vars(b)) %>%
      col_is_date(vars(date)) %>%
      col_is_posix(vars(date_time)) %>%
      col_is_integer(vars(a)) %>%
      col_is_numeric(vars(d)) %>%
      col_is_logical(vars(e)) %>%
      col_vals_between(vars(c), left = vars(a), right = vars(d), na_pass = TRUE) %>%
      col_vals_equal(vars(d), vars(d), na_pass = TRUE) %>%
      col_vals_expr(expr(c %% 1 == 0)) %>%
      col_vals_gt(vars(date_time), vars(date), na_pass = TRUE) %>%
      col_vals_gt(vars(b), vars(g), na_pass = TRUE) %>%
      col_vals_gte(vars(a, b, d), 0, na_pass = TRUE) %>%
      col_vals_regex(vars(b), "[1-9]-[a-z]{3}-[0-9]{3}") %>%
      rows_distinct() %>%
      col_vals_gt(vars(d), 100) %>%
      col_vals_not_null(vars(date_time))
  )
})
