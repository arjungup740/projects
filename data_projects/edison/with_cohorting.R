## just doing this with cohorting
library(data.table)
library(ggplot2)
library(zoo)
raw = fread('/Users/arjungup/projects/data_projects/edison/edison_dominos_receipts.csv')

# turn numbers into numbers
raw[, order_number := as.numeric(order_number) ]
# when you consider we really only need order time
raw[, order_time := as.Date(order_time, fmt = '%Y-%m-%d')]

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
#saveRDS(order_table, 'order_table.rds')

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

spend_by_day = aggregateOrderTable(order_table, 'daily')
spend_by_month = aggregateOrderTable(order_table, 'monthly')
quickLineGraph(spend_by_month, 'month', 'yoy_normalized_spend')
spend_by_quarter = aggregateOrderTable(order_table, 'quarterly')
quickLineGraph(spend_by_quarter[quarter != '2018 Q3'], 'quarter', 'yoy_normalized_spend') # hm not great
spend_by_dpz_quarter = aggregateOrderTable(order_table, 'dpz_quarterly')
quickLineGraph(spend_by_dpz_quarter[dpz_quarter != '2018 Q3'], 'dpz_quarter', 'yoy_normalized_spend') # hm not great

###### we try cohorting without worrying about dpz_quarters for a second
order_table[, user_date_of_birth := min(order_time), by = user_id] # get birth
order_table[, user_cohort := as.yearqtr(user_date_of_birth)] # assign them to a cohort
cohort_sizes = order_table[, .(count_unique_customers = uniqueN(user_id)), by = user_cohort] # see number of people in each cohort

order_table[quarter == '2016 Q1' & user_cohort == '2015 Q1', uniqueN(user_id)] # get a count of people who were born in 2015 Q1 transacting in 2016 Q1 # 21815
order_table[quarter == cohort_sizes[, user_cohort][5] & user_cohort == cohort_sizes[, user_cohort][1], uniqueN(user_id)]
order_table[quarter == '2016 Q2' & user_cohort == '2015 Q2', uniqueN(user_id)] # 12593
order_table[quarter == '2018 Q2' & user_cohort == '2017 Q2', uniqueN(user_id)]
# what we want to do is say give me the spend of all people who were born a year before the previous quarter
all_usable_cohorts = cohort_sizes[, user_cohort][1:10] # stop afer 2017 Q2
for( cohort in all_usable_cohorts ){ 
  print(order_table[quarter == cohort + 1 & user_cohort == cohort, .(num_users = uniqueN(user_id), cohort_spend = sum(order_total_amount))])
}

## read in actuals
revenue_actuals = fread("/Users/arjungup/Documents/data_projects/edison/dpz_revenue_actuals.csv")
setnames(revenue_actuals, 'yoy_tota_revenue', 'yoy_total_revenue')
fmt = '%m/%d/%Y'
revenue_actuals[, c('date_began', 'date_ended', 'quarter') := list(as.Date(date_began, fmt), as.Date(date_ended, fmt), as.yearqtr(quarter))]
quickLineGraph(revenue_actuals, 'quarter', 'yoy_domestic_franchise_revenue')
quickLineGraph(revenue_actuals, 'quarter', 'yoy_domestic_company_owned_revenue')
quickLineGraph(revenue_actuals, 'quarter', 'yoy_total_revenue')

