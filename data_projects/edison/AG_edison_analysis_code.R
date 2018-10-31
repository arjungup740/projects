## Edison challenge
library(data.table)
library(ggplot2)
library(zoo)
raw = fread('/Users/arjungup/projects/data_projects/edison/edison_dominos_receipts.csv')
# save as RDS for hopefully faster reading
saveRDS(raw, 'raw_edison_data.rds')
#saveRDS(order_table, 'order_table_edison_data.rds')
readRDS()
uniqueN(raw$user_id)
raw[, max(order_time, na.rm = T)]
# this is 10bn rows of 30 variables. 4gb. hm

# explore
head(raw)
raw[, unique(merchant_name)] # only DPZ
# turn dates into, well, dates
fmt = '%Y-%m-%d'
# Can come up with a way retain the timestamps if you need them but probably not super relevant

# turn numbers into numbers
raw[, order_number := as.numeric(order_number) ]
# when you consider we really only need order time
raw[, order_time := as.Date(order_time, fmt = '%Y-%m-%d')]

# # make things into dates
# raw[, c('order_time', 'email_time', 'update_time', 'insert_time', 'user_create_time', 'user_last_process_day') := 
#       list( as.Date(order_time, fmt = '%Y-%m-%d'), as.Date(email_time, fmt = '%Y-%m-%d'), 
#             as.Date(update_time, fmt = '%Y-%m-%d') , as.Date(insert_time, fmt = '%Y-%m-%d'),
#             as.Date(user_create_time, fmt = '%Y-%m-%d'), as.Date(user_last_process_day, fmt = '%Y-%m-%d'))  ]

# order table
setkey(raw, order_time, user_id, order_total_amount)
#setkey(order_table, order_time, user_id, order_total_amount)
# remove international domains
print(setorder(raw[, .N, by = from_domain ], -N))
summary(raw[ from_domain == '']) # this is reasonable
raw = raw[ from_domain %in% c('orders@dominos.com', 'orders@dominospr.com', '')]
summary(raw)
# winsorize
winsor_value = raw[, quantile(order_total_amount, .999)]# get 99.99th percentile
raw[ order_total_amount > winsor_value, order_total_amount := winsor_value ]

summary(raw)

test = '2016-12-06 19:49:00'
as.Date(test, '%Y-%m-%d')
summary(raw) # lots of things are character, that needs to be fixed. 
# order_points, product_reseller, SKU, order_discount, item_id, all totally null
raw[, c('order_points', 'product_reseller', 'SKU', 'order_discount', 'item_id') := NULL  ]
######### sanity checks and understanding what we're working with
# how many distinct users
raw[, uniqueN(order_number)] # only 1bn unique order numbers
raw[, uniqueN(user_id)] # 604k users
raw[, uniqueN(shipping_zip)] #21906 shipping zips, marketshare of zips would be a worthwhile sanity check
print(setorder(raw[, .N, by = from_domain ], -N))
quickLineGraph(raw[, .N, by = user_create_time ], 'user_create_time', 'N')


# example of multiple distinct items per order
raw[ user_id == 'ff45d31eb672c2f315e0bee60057edce72b4878d2d3cc7a6bc3aecb34fbf00e2' & order_number == 482127, 
     c('user_id', 'merchant_name', 'order_number', 'order_time', 'order_total_amount', 
       # 'order_shipping', 'order_tax', 'item_total', 'order_total_qty', 
       'quantity', 'item_price', 'product_description'), with  = F ]

# example of a legitimately erroneous transaction
raw[user_id == '5b0ee79d44928539eb74442cf7e6e07ee6f107685e302bdc545d041156478739' & order_time == '2015-06-07' ] # oh it's currency related
raw[ order_total_amount > 500, unique(from_domain)] # some canadian + us in there
raw[ order_total_amount > 500 & from_domain == "orders@dominos.com"] 
# yeah let's just winsorize american transactions and drop the rest. Or you know even just winsorize order_total_amounts
order_table
### check on the dates
multiple_update_times = raw[, list(distinct_update_times = uniqueN(update_time), 
                                   distinct_insert_times = uniqueN(insert_time)), by = .(user_id, order_time, order_number)]
multiple_update_times[distinct_update_times > 1] # only 419 instances that have multiple distinct update times -- this might not matter
multiple_update_times[distinct_insert_times > 1]
# Looks like we get one row per line item on the receipt
# user_id, order_number, order_time should be one instance of an order. 
count_table = raw[, .N, by = .(user_id, order_number, order_time)] # we have 4 bn orders
setorder(count_table, -N)
count_table[N > 1] # the interpretation of N here is the number of distinct items ordered per instance. Ie, number of 'SKUs'
hist(count_table$N)
ggplot(count_table, aes(x = N)) + geom_histogram()
raw[user_id == 'c766fa156c1ce2f78d801f1945f461a386f6328cdbed86e5d1892a7e260f31b2' & order_time == '2018-01-23' & order_number == 1] # so this looks like a straight up dupe.

raw[user_id == '5b0ee79d44928539eb74442cf7e6e07ee6f107685e302bdc545d041156478739' & order_time == '2015-06-07' ] 


# another sanity check is to see that the total amounts are equal to order_total_qtys. We should do it, but maybe in a bit
total_quantity_check_table = raw[, list(computed_total_quantity = sum(quantity), 
                                        min_order_total_qty = min(order_total_qty),
                                        max_order_total_qty = max(order_total_qty) ),
                                              by = .(user_id, order_number, order_time)]
total_quantity_check_table[ computed_total_quantity == min_order_total_qty & min_order_total_qty ==  max_order_total_qty]
# this is also internally consistent. I'm not sure if this is a trivial statement but feels like it was worth checking. 

###### create order table

## can try this idea about normalizing by when users were created
# let's just see that no individual user has multiple create times, then we can add this count to the aggregated tables
count_of_create_times = raw[, uniqueN(user_create_time), by = user_id][V1 > 1]# they are indeed unique
### quick sanity checks around using the max or min total amount for an instance
order_table = raw[, list(order_total_max = max(order_total_amount), 
                         order_total_min = min(order_total_amount),
                         order_total_qty = sum(quantity)), # as we showed above this is correct
                  by = .(user_id, order_number, order_time, user_create_time)] # this field is unique to user_id
order_table[ order_total_max != order_total_min] # only issue here is the NAs, which is fine. It's 12 orders
order_table[ is.na(order_time)] # only 44 here
# we've just shown that for all our instances of an order total are consistent, which is good.
order_table[, order_total_min := NULL]; setnames(order_table, 'order_total_max', 'order_total_amount')
# add months and quarters for aggregation
order_table[, c('month', 'quarter') := list(as.yearmon(order_time), as.yearqtr(order_time))]
order_table = order_table[!is.na(order_time)] # this causes issues down the line
setkey(order_table, order_time, user_id, order_total_amount)
saveRDS(order_table, 'order_table.rds')
### create DPZ quarters. they have 3 12-week quarters and 1 16 week quarter, so could be causing a difference
# In an ideal world we'd figure out foverlaps but this is faster for the moment
order_table[ order_time <= '2015-03-22', dpz_quarter := '2015 Q1']
order_table[ order_time >= '2015-03-23' & order_time <= '2015-06-14', dpz_quarter := '2015 Q2']
order_table[ order_time >= '2015-06-15' & order_time <= '2015-09-06', dpz_quarter := '2015 Q3']
order_table[ order_time >= '2015-09-07' & order_time <= '2016-01-03', dpz_quarter := '2015 Q4']
order_table[ order_time >= '2016-01-04' & order_time <= '2016-03-27', dpz_quarter := '2016 Q1']
order_table[ order_time >= '2016-03-28' & order_time <= '2016-06-19', dpz_quarter := '2016 Q2']
order_table[ order_time >= '2016-06-20' & order_time <= '2016-09-11', dpz_quarter := '2016 Q3']
order_table[ order_time >= '2016-09-12' & order_time <= '2017-01-01', dpz_quarter := '2016 Q4']
order_table[ order_time >= '2017-01-02' & order_time <= '2017-03-26', dpz_quarter := '2017 Q1']
order_table[ order_time >= '2017-03-27' & order_time <= '2017-06-18', dpz_quarter := '2017 Q2']
order_table[ order_time >= '2017-06-19' & order_time <= '2017-09-10', dpz_quarter := '2017 Q3']
order_table[ order_time >= '2017-09-11' & order_time <= '2017-12-31', dpz_quarter := '2017 Q4']
order_table[ order_time >= '2018-01-01' & order_time <= '2018-03-25', dpz_quarter := '2018 Q1']
order_table[ order_time >= '2018-03-26' & order_time <= '2018-06-17', dpz_quarter := '2018 Q2']
order_table[ order_time >= '2018-06-18', dpz_quarter := '2018 Q3']
order_table[, dpz_quarter := as.yearqtr(dpz_quarter)]
## function to aggregate
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

spend_by_day = aggregateOrderTable(order_table, 'daily')
spend_by_month = aggregateOrderTable(order_table, 'monthly')
merge(spend_by_month, count)
quickLineGraph(spend_by_month, 'month', 'yoy_normalized_spend')
quickLineGraph(spend_by_month, 'month', 'basket_size')
spend_by_quarter = aggregateOrderTable(order_table, 'quarterly')
quickLineGraph(spend_by_quarter[quarter != '2018 Q3'], 'quarter', 'yoy_normalized_spend') # hm not great
spend_by_dpz_quarter = aggregateOrderTable(order_table, 'dpz_quarterly')
quickLineGraph(spend_by_dpz_quarter[dpz_quarter != '2018 Q3'], 'dpz_quarter', 'yoy_normalized_spend') # hm not great
quickLineGraph(spend_by_dpz_quarter[dpz_quarter != '2018 Q3'], 'dpz_quarter', 'basket_size') # hm not great


quickLineGraph(spend_by_dpz_quarter[dpz_quarter != '2018 Q3'], 'dpz_quarter', 'normalized_spend')
quickLineGraph(spend_by_dpz_quarter[dpz_quarter != '2018 Q3'], 'dpz_quarter', 'total_spend')
quickLineGraph(spend_by_dpz_quarter[dpz_quarter != '2018 Q3'], 'dpz_quarter', 'yoy_total_spend') # yeah this is extremely wrong

## read in actuals
revenue_actuals = fread("/Users/arjungup/Documents/data_projects/edison/dpz_revenue_actuals.csv")
setnames(revenue_actuals, 'yoy_tota_revenue', 'yoy_total_revenue')
fmt = '%m/%d/%Y'
revenue_actuals[, c('date_began', 'date_ended', 'quarter') := list(as.Date(date_began, fmt), as.Date(date_ended, fmt), as.yearqtr(quarter))]
quickLineGraph(revenue_actuals, 'quarter', 'yoy_domestic_franchise_revenue')
quickLineGraph(revenue_actuals, 'quarter', 'yoy_domestic_company_owned_revenue')
quickLineGraph(revenue_actuals, 'quarter', 'yoy_total_revenue')

## plot actuals and predictions on one graph
results_frame = merge(revenue_actuals, spend_by_dpz_quarter[ dpz_quarter != '2015 Q1' & dpz_quarter != '2015 Q2' & dpz_quarter != '2015 Q3' & dpz_quarter != '2015 Q4' & dpz_quarter != '2018 Q3'], by.x = 'quarter', by.y = 'dpz_quarter')
ggplot(results_frame, aes(quarter, yoy_normalized_spend)) + geom_line() + 
        geom_line(aes(y = yoy_domestic_franchise_revenue, color = 'red')) +
        geom_line(aes(y = yoy_domestic_company_owned_revenue, color = 'green')) +
        geom_line(aes(y = yoy_total_revenue, color = 'blue')) + 
        ylab('Quarterly YoY Growth') + theme(legend.position="none") + xlab("Domino's Quarter") +
        ggtitle('Prediction Vs. Actuals')
# ok try debugging this insanity
# sanity check that all the dates that should be there are.
date_sequence = seq(as.Date('2015-01-01'), as.Date('2018-07-31'), 1)
table_of_dates = data.table(true_dates = date_sequence)
merged = merge(table_of_dates, spend_by_day, by.x = 'true_dates', by.y = 'date')
setdiff(merged$true_dates, spend_by_day$date) # they really are all there it seems

## try new way of normalizing
#count_of_create_times = order_table[, .N, by = user_create_time]; setkey(count_of_create_times, user_create_time)
# actually, .N isn't the right way to do it (count(*)) because then a create date gets extra weight if the user transacted on multiple days
count_of_create_times = order_table[, .(num_customers_born_on_day = uniqueN(user_id)), by = user_create_time]; setkey(count_of_create_times, user_create_time) # number of distinct people born on this day
count_of_create_times[ user_create_time < '2015-01-01', user_create_time := as.Date('2015-01-01')] # make everything before 2015-01-01 equal to this date
count_of_create_times[, c('month', 'quarter') := list(as.yearmon(user_create_time), as.yearqtr(user_create_time))]
create_times_quarterly = count_of_create_times[, .(period_sum = sum(num_customers_born_on_day)), by = quarter]
create_times_quarterly[, cumulative_period_sum := cumsum(period_sum)]
spend_by_quarter = merge(spend_by_quarter, create_times_quarterly, by = 'quarter')
spend_by_quarter[, new_normalized_spend := total_spend / cumulative_period_sum] # ok this is nonsense



order_table[ order_time < user_create_time] # 1.6 mn people placed orders before they were created?
# our underprediction actually gets worse when you remove these, which is interesting
only_2017q1 = aggregateOrderTable(order_table[dpz_quarter == '2017 Q1'], 'daily')
quickLineGraph(only_2017q1, 'date', 'yoy_normalized_spend')

quickLineGraph(spend_by_month[ date >= '2017-01-02' & date <= '2017-03-26' ], 'date', 'normalized_spend')

# Looking at the time related things
ggplot(raw[, .N, by = .(order_time)], aes(order_time, N)) + geom_line()
ggplot(raw[, .N, by = .(email_time)], aes(email_time, N)) + geom_line()
ggplot(raw[, .N, by = .(update_time)], aes(update_time, N)) + geom_line() # there was one day we just updated a ton
ggplot(raw[, .N, by = .(insert_time)], aes(insert_time, N)) + geom_line()
