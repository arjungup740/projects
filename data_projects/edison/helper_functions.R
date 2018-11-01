aggregateOrderTable = function(order_table, cadence) { # cadence can be 'daily', 'monthly', 'quarterly', 'dpz_quarterly'
  column_to_aggregate_by = switch(cadence, daily = 'order_time', monthly = 'month', quarterly = 'quarter', dpz_quarterly = 'dpz_quarter')
  spend_by_table = order_table[, list(total_spend = sum(order_total_amount), 
                                      total_orders = .N, 
                                      num_distinct_users = uniqueN(user_id)), 
                               by = get(column_to_aggregate_by)]
  spend_by_table[, basket_size := total_spend / total_orders ] # get AOVs
  spend_by_table[, normalized_spend := total_spend / num_distinct_users ]# get normalized spend. Here we normalize by number of distinct users. What we really want is to divide by total panel spend
  n = switch(cadence, daily = 365, monthly = 12, quarterly = 4, dpz_quarterly = 4)# correct lag for yoy computation
  spend_by_table[, yoy_normalized_spend := normalized_spend / shift(normalized_spend, n) - 1]# get yoy normalized values
  spend_by_table[, yoy_total_spend := total_spend / shift(total_spend, n) - 1]# this isn't right but just try it
  name_hack_variable = switch(cadence, daily = 'date', monthly = 'month', quarterly = 'quarter', dpz_quarterly = 'dpz_quarter')
  setnames(spend_by_table, 'get', name_hack_variable)
}

quickLineGraph = function(dat, x_variable, y_variable) {
  print(ggplot(dat, aes_string(x = x_variable, y = y_variable)) + geom_line())
}

convertToDPZQuarter = function(order_table, variable_to_bound_by, variable_to_create) {
  order_table[ eval(parse(text = variable_to_bound_by)) <= '2015-03-22', (variable_to_create) := '2015 Q1']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2015-03-23' & eval(parse(text = variable_to_bound_by)) <= '2015-06-14', (variable_to_create) := '2015 Q2']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2015-06-15' & eval(parse(text = variable_to_bound_by)) <= '2015-09-06', (variable_to_create) := '2015 Q3']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2015-09-07' & eval(parse(text = variable_to_bound_by)) <= '2016-01-03', (variable_to_create) := '2015 Q4']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2016-01-04' & eval(parse(text = variable_to_bound_by)) <= '2016-03-27', (variable_to_create) := '2016 Q1']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2016-03-28' & eval(parse(text = variable_to_bound_by)) <= '2016-06-19', (variable_to_create) := '2016 Q2']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2016-06-20' & eval(parse(text = variable_to_bound_by)) <= '2016-09-11', (variable_to_create) := '2016 Q3']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2016-09-12' & eval(parse(text = variable_to_bound_by)) <= '2017-01-01', (variable_to_create) := '2016 Q4']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2017-01-02' & eval(parse(text = variable_to_bound_by)) <= '2017-03-26', (variable_to_create) := '2017 Q1']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2017-03-27' & eval(parse(text = variable_to_bound_by)) <= '2017-06-18', (variable_to_create) := '2017 Q2']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2017-06-19' & eval(parse(text = variable_to_bound_by)) <= '2017-09-10', (variable_to_create) := '2017 Q3']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2017-09-11' & eval(parse(text = variable_to_bound_by)) <= '2017-12-31', (variable_to_create) := '2017 Q4']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2018-01-01' & eval(parse(text = variable_to_bound_by)) <= '2018-03-25', (variable_to_create) := '2018 Q1']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2018-03-26' & eval(parse(text = variable_to_bound_by)) <= '2018-06-17', (variable_to_create) := '2018 Q2']
  order_table[ eval(parse(text = variable_to_bound_by)) >= '2018-06-18', (variable_to_create) := '2018 Q3']
}