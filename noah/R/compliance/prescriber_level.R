
x = dt_txn[!duplicated(dt_txn)]

# data patient, drug, week ------------------------------------------------


dt_prescriber_patient_drug_week = x[, .(Prescriber_ID, Patient_ID, Drug_ID, Dispense_Week, RepeatsTotal_Qty, RepeatsLeft_Qty, Script_Qty)]

setorderv(dt_prescriber_patient_drug_week, c("Prescriber_ID", "Patient_ID", "Drug_ID", "Dispense_Week"))


# bought a drug for more than 5 times -------------------------------------


dt_prescriber_patient_drug_week_N = dt_prescriber_patient_drug_week[, .N , by = c("Prescriber_ID", "Patient_ID", "Drug_ID")]
dt_prescriber_patient_drug_week_N[N > 5]

dt_prescriber_patient_drug_week_5 = merge(dt_prescriber_patient_drug_week, dt_prescriber_patient_drug_week_N[N > 5], by = c("Prescriber_ID", "Patient_ID", "Drug_ID"))



# week diff between 2 txns for a drug -------------------------------------


diffWeeks = function(date1, date2){
  x = as.numeric((as.POSIXct(date1) - as.POSIXct(date2))) / 7
  
  return(x)
}

dt_prescriber_patient_drug_week_5[, interval := RepeatsLeft_Qty - shift(RepeatsLeft_Qty, type = "lead"), by = c("Prescriber_ID", "Patient_ID", "Drug_ID")]
dt_prescriber_patient_drug_week_5[, interval_adjusted := ifelse(interval < 0, shift(RepeatsTotal_Qty, type = "lead") - shift(RepeatsLeft_Qty, type = "lead"), interval)]
dt_prescriber_patient_drug_weekDiff = dt_prescriber_patient_drug_week_5[, weekDiff := diffWeeks(shift(Dispense_Week, 1, type = "lead"), Dispense_Week) / interval_adjusted, by = c("Prescriber_ID", "Patient_ID", "Drug_ID")]


# remove outliers ---------------------------------------------------------


# remove NAs
dt_prescriber_patient_drug_weekDiff = dt_prescriber_patient_drug_weekDiff[!is.na(weekDiff)]

# normal weekDiff
weekDiff_prescriber_normal = quantile(dt_prescriber_patient_drug_weekDiff$weekDiff, probs = seq(0, 1, .05), na.rm = T)
# 0%          5%         10%         15%         20%         25%         30% 
# -17452800.0         3.0         3.0         4.0         4.0         4.0         4.0 
# 35%         40%         45%         50%         55%         60%         65% 
# 4.0         5.0         5.0         5.0         6.5         8.0         8.5 
# 70%         75%         80%         85%         90%         95%        100% 
# 9.0        11.0        21.5    259200.0    691200.0         Inf         Inf 
dt_prescriber_normal = dt_prescriber_patient_drug_weekDiff[, all(weekDiff >= 1 & weekDiff <= weekDiff_prescriber_normal[["80%"]]), by = .(Prescriber_ID, Patient_ID, Drug_ID)]
dt_prescriber_normal = dt_prescriber_normal[V1 == T]
dt_prescriber_patient_drug_weekDiff_norm = merge(dt_prescriber_normal, dt_prescriber_patient_drug_weekDiff, by = c("Prescriber_ID", "Patient_ID", "Drug_ID"))

# normal weekDiff by drug
dt_prescriber_drug_weekDiff_normal = dt_prescriber_patient_drug_weekDiff_norm[, .(WD_q05 = quantile(weekDiff, probs = c(.05), na.rm = T)
                                                            , WD_q85 = quantile(weekDiff, probs = c(.85), na.rm = T)), by = .(Prescriber_ID, Drug_ID)]

# normal popularity by drug
dt_prescriber_drug_pop_normal = dt_prescriber_patient_drug_weekDiff_norm[, .(N_q05 = quantile(N, probs = c(.05), na.rm = T)
                                                       , N_q85 = quantile(N, probs = c(.85), na.rm = T)), by = .(Prescriber_ID, Drug_ID)]

# normal popularity and freq
dt_prescriber_drug_freq = merge(dt_prescriber_patient_drug_weekDiff_norm, dt_prescriber_drug_weekDiff_normal, by = c("Prescriber_ID", "Drug_ID"))
dt_prescriber_drug_freq_pop = merge(dt_prescriber_drug_freq, dt_prescriber_drug_pop_normal, by = c("Prescriber_ID", "Drug_ID"))


# freq and pop by prescriber ----------------------------------------------

dt_drug_freq_pop_norm = readRDS("../../data/MelbDatathon2017/New/dt_drug_freq_pop_norm.rds")

dt_prescriber_drug_freq_pop_norm = merge(dt_prescriber_drug_freq_pop
                                         , dt_drug_freq_pop_norm
                                         , by = "Drug_ID")
dt_prescriber_drug_freq_pop_norm = dt_prescriber_drug_freq_pop_norm[weekDiff >= WD_q05 & weekDiff <= WD_q85 & N >= N_q05 & N <= N_q85]

dt_prescriber_compliance = dt_prescriber_drug_freq_pop_norm[, .(meanVar = mean(abs(weekDiff - med))
                                     , sdVar = sd(abs(weekDiff - med))
                                     , pop = .N), by = "Prescriber_ID"]
dt_prescriber_compliance[, rankN := frank(-pop, ties.method = "first")]

setorder(dt_prescriber_compliance, meanVar)
dt_prescriber_compliance[rankN <= 100]

ggplot(dt_prescriber_compliance[rankN <= 100], aes(x = rankN, y = meanVar)) +
  geom_point(size = 4, alpha = .4)
plot(dt_prescriber_compliance$rankN, dt_prescriber_compliance$meanVar)
