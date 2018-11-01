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
convertToDPZQuarter(order_table, 'order_time', 'dpz_quarter')
order_table[, dpz_quarter := as.yearqtr(dpz_quarter)]

spend_by_day = aggregateOrderTable(order_table, 'daily')
spend_by_month = aggregateOrderTable(order_table, 'monthly')
quickLineGraph(spend_by_month, 'month', 'yoy_normalized_spend')
spend_by_quarter = aggregateOrderTable(order_table, 'quarterly')
quickLineGraph(spend_by_quarter[quarter != '2018 Q3'], 'quarter', 'yoy_normalized_spend') # hm not great
spend_by_dpz_quarter = aggregateOrderTable(order_table, 'dpz_quarterly')
quickLineGraph(spend_by_dpz_quarter[dpz_quarter != '2018 Q3'], 'dpz_quarter', 'yoy_normalized_spend') # hm not great

###### cohorting without worrying about dpz_quarters for a second
order_table[, user_date_of_birth := min(order_time), by = user_id] # get birth time
# assign cohorts based on DPZ time
variable_to_bound_by = 'user_date_of_birth'
variable_to_create = 'dpz_quarter_of_birth'
convertToDPZQuarter(order_table, variable_to_bound_by, variable_to_create)
order_table[, dpz_quarter_of_birth := as.yearqtr(dpz_quarter_of_birth)]

cohort_sizes = order_table[, .(count_unique_customers = uniqueN(user_id)), by = dpz_quarter_of_birth] # see number of people in each cohort


##### to start what we want to do is say give me the spend of all people who were born a year before the previous quarter
### toy example
survivors = order_table[dpz_quarter == '2018 Q1' & dpz_quarter_of_birth == '2017 Q1', unique(user_id) ] # survivors
order_table[ user_id %in% survivors & dpz_quarter == '2017 Q1', sum(order_total_amount)]
order_table[ user_id %in% survivors & dpz_quarter == '2018 Q1', sum(order_total_amount)]

### now scale up.
# we can get the naive predictions all at once actually
all_usable_cohorts = as.yearqtr(cohort_sizes[, dpz_quarter_of_birth][1:10])
 yoy_vector =    
    sapply(all_usable_cohorts, function(cohort) { 
    survivors = order_table[dpz_quarter == cohort + 1 & dpz_quarter_of_birth == cohort, unique(user_id)] 
    cohort_initial_spend = order_table[ user_id %in% survivors & dpz_quarter == cohort, sum(order_total_amount)]
    cohort_one_year_later_spend = order_table[ user_id %in% survivors & dpz_quarter == cohort + 1, sum(order_total_amount)]
    cohort_one_year_later_spend / cohort_initial_spend - 1
    }
  )
quarter_spend_frame_naive_cohorts = data.table(dpz_quarter = all_usable_cohorts + 1, yoy_signal = yoy_vector)
quickLineGraph(quarter_spend_frame_naive_cohorts, 'dpz_quarter', 'yoy_signal')

# can we get the spend of all eligible cohorts for a given quarter?

# results + intercept adjustment
results_frame = merge(revenue_actuals, quarter_spend_frame_naive_cohorts[ dpz_quarter != '2015 Q1' & dpz_quarter != '2015 Q2' & dpz_quarter != '2015 Q3' & dpz_quarter != '2015 Q4' & dpz_quarter != '2018 Q3'], by.x = 'quarter', by.y = 'dpz_quarter')
adj = mean(results_frame$yoy_total_revenue - results_frame$yoy_signal)# actual - predicted
results_frame[, yoy_signal_adj := yoy_signal + adj]

ggplot(results_frame, aes(quarter, yoy_signal_adj)) + geom_line() + 
  geom_line(aes(y = yoy_domestic_franchise_revenue, color = 'red')) +
  geom_line(aes(y = yoy_domestic_company_owned_revenue, color = 'green')) +
  geom_line(aes(y = yoy_total_revenue, color = 'blue')) + 
  ylab('Quarterly YoY Growth') + theme(legend.position="none") + xlab("Domino's Quarter") +
  ggtitle('Prediction Vs. Actuals')

ggplot(results_frame, aes(quarter, yoy_domestic_franchise_revenue), color = 'red') + geom_line() + 
  geom_line(aes(y = yoy_domestic_franchise_revenue, color = 'red')) +
  geom_line(aes(y = yoy_domestic_company_owned_revenue, color = 'green')) +
  geom_line(aes(y = yoy_total_revenue, color = 'blue')) + 
  ylab('Quarterly YoY Growth') + theme(legend.position="none") + xlab("Domino's Quarter") +
  ggtitle('Actuals')

## read in actuals
revenue_actuals = fread("/Users/arjungup/projects/data_projects/edison/dpz_revenue_actuals.csv")
# deal with minor formatting errors
updated_column_names = sapply(names(revenue_actuals), function(string){ gsub(' ','_', string)}) # add "_"
names(revenue_actuals) = updated_column_names
revenue_actuals[date_began == '', date_began := NA] # this doesn't matter
fmt = '%m/%d/%Y'
revenue_actuals[, c('date_began', 'date_ended', 'quarter') := list(as.Date(date_began, fmt), as.Date(date_ended, fmt), as.yearqtr(quarter))]
quickLineGraph(revenue_actuals, 'quarter', 'yoy_domestic_franchise_revenue')
quickLineGraph(revenue_actuals, 'quarter', 'yoy_domestic_company_owned_revenue')
quickLineGraph(revenue_actuals, 'quarter', 'yoy_total_revenue')

# an intercept adjustment -- should be pretty easy
revenue_actuals

## plot actuals and predictions on one graph
results_frame = merge(revenue_actuals, spend_by_dpz_quarter[ dpz_quarter != '2015 Q1' & dpz_quarter != '2015 Q2' & dpz_quarter != '2015 Q3' & dpz_quarter != '2015 Q4' & dpz_quarter != '2018 Q3'], by.x = 'quarter', by.y = 'dpz_quarter')
ggplot(results_frame, aes(quarter, yoy_normalized_spend)) + geom_line() + 
  geom_line(aes(y = yoy_domestic_franchise_revenue, color = 'red')) +
  geom_line(aes(y = yoy_domestic_company_owned_revenue, color = 'green')) +
  geom_line(aes(y = yoy_total_revenue, color = 'blue')) + 
  ylab('Quarterly YoY Growth') + theme(legend.position="none") + xlab("Domino's Quarter") +
  ggtitle('Prediction Vs. Actuals')


