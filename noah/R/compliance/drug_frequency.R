source("R/load.R")

require(lubridate)
require(ggplot2)


# remove duplicates and non-chronicIllness --------------------------------


x = x[!duplicated(x)]
x= x[!is.na(ChronicIllness)]


# data patient, drug, week ------------------------------------------------


dt_patient_drug_week = x[, .(Patient_ID, Drug_ID, Dispense_Week, RepeatsTotal_Qty, RepeatsLeft_Qty, Script_Qty)]

setorderv(dt_patient_drug_week, c("Patient_ID", "Drug_ID", "Dispense_Week"))


# bought a drug for more than 5 times -------------------------------------


dt_patient_drug_week_N = dt_patient_drug_week[, .N , by = c("Patient_ID", "Drug_ID")]
dt_patient_drug_week_N[N > 5]

dt_patient_drug_week_5 = merge(dt_patient_drug_week, dt_patient_drug_week_N[N > 5], by = c("Patient_ID", "Drug_ID"))



# week diff between 2 txns for a drug -------------------------------------


diffWeeks = function(date1, date2){
  x = as.numeric((as.POSIXct(date1) - as.POSIXct(date2))) / 7
  
  return(x)
}

dt_patient_drug_week_5[, interval := RepeatsLeft_Qty - shift(RepeatsLeft_Qty, type = "lead"), by = c("Patient_ID", "Drug_ID")]
dt_patient_drug_week_5[, interval_adjusted := ifelse(interval < 0, shift(RepeatsTotal_Qty, type = "lead") - shift(RepeatsLeft_Qty, type = "lead"), interval)]
dt_patient_drug_weekDiff = dt_patient_drug_week_5[, weekDiff := diffWeeks(shift(Dispense_Week, 1, type = "lead"), Dispense_Week) / interval_adjusted, by = c("Patient_ID", "Drug_ID")]


# remove outliers ---------------------------------------------------------


# remove NAs
dt_patient_drug_weekDiff = dt_patient_drug_weekDiff[!is.na(weekDiff)]

# normal weekDiff
weekDiff_normal = quantile(dt_patient_drug_weekDiff$weekDiff, probs = seq(0, 1, .05), na.rm = T)
# 0%      5%     10%     15%     20%     25%     30%     35%     40%     45%     50%     55% 
#   0       3       3       4       4       4       4       4       5       5       5       7 
# 60%     65%     70%     75%     80%     85%     90%     95%    100% 
# 10      14      16      17      19      29  345600 1468800     Inf 
dt_normal = dt_patient_drug_weekDiff[, all(weekDiff >= 1 & weekDiff <= weekDiff_normal[["85%"]]), by = .(Patient_ID, Drug_ID)]
dt_normal = dt_normal[V1 == T]
dt_patient_drug_weekDiff_norm = merge(dt_normal, dt_patient_drug_weekDiff, by = c("Patient_ID", "Drug_ID"))

# normal weekDiff by drug
dt_drug_weekDiff_normal = dt_patient_drug_weekDiff_norm[, .(WD_q05 = quantile(weekDiff, probs = c(.05), na.rm = T)
                                                    , WD_q85 = quantile(weekDiff, probs = c(.85), na.rm = T)), by = Drug_ID]

# normal popularity by drug
dt_drug_pop_normal = dt_patient_drug_weekDiff_norm[, .(N_q05 = quantile(N, probs = c(.05), na.rm = T)
                                                  , N_q85 = quantile(N, probs = c(.85), na.rm = T)), by = Drug_ID]

# drug frequency and popularity -------------------------------------------

dt_drug_freq = merge(dt_patient_drug_weekDiff_norm, dt_drug_weekDiff_normal, by = c("Drug_ID"))
dt_drug_freq_pop = merge(dt_drug_freq, dt_drug_pop_normal, by = c("Drug_ID"))

dt_drug_freq_pop_norm = dt_drug_freq_pop[weekDiff >= WD_q05 & weekDiff <= WD_q85 & N >= N_q05 & N <= N_q85
                 , .(med = median(weekDiff)
                     , mad = mad(weekDiff)
                     , coeff_med = mad(weekDiff) / median(weekDiff)
                     , mean = mean(weekDiff)
                     , sd = sd(weekDiff)
                     , coeff_var = var(weekDiff) / mean(weekDiff)
                     , pop = .N), by = Drug_ID]

dt_drug_freq_pop_norm[, rankN := frank(-pop, ties.method = "first")]

setorder(dt_drug_freq_pop_norm, mad)

dt_plot_drug_freq_pop_norm = merge(dt_drug_freq_pop_norm, dt_drug, by.x = "Drug_ID", by.y = "MasterProductID")
ggplot(dt_plot_drug_freq_pop_norm, aes(x = rankN, y = coeff_var, colour = EthicalCategoryName)) +
  geom_point()

dt_plot_drug_freq_pop_norm[rankN <= 100 & EthicalCategoryName == "ETHICAL NON PBS"]


