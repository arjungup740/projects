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
