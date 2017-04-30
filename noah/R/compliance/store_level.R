# data store, patient, drug, week -----------------------------------------


dt_store_patient_drug_week = x[, .(Store_ID, Patient_ID, Drug_ID, Dispense_Week, RepeatsTotal_Qty, RepeatsLeft_Qty, Script_Qty)]

setorderv(dt_store_patient_drug_week, c("Patient_ID", "Drug_ID", "Dispense_Week"))


# bought a drug for more than 5 times in a store --------------------------


dt_store_patient_drug_week_N = dt_store_patient_drug_week[, .N , by = c("Store_ID", "Patient_ID", "Drug_ID")]
dt_store_patient_drug_week_N[N > 5]

dt_store_patient_drug_week_5 = merge(dt_store_patient_drug_week, dt_store_patient_drug_week_N[N > 5], by = c("Store_ID", "Patient_ID", "Drug_ID"))



# week diff between 2 txns for a drug at a store --------------------------


diffWeeks = function(date1, date2){
  x = as.numeric((as.POSIXct(date1) - as.POSIXct(date2))) / 7
  
  return(x)
}

dt_store_patient_drug_week_5[, interval := RepeatsLeft_Qty - shift(RepeatsLeft_Qty, type = "lead"), by = c("Store_ID", "Patient_ID", "Drug_ID")]
dt_store_patient_drug_week_5[, interval_adjusted := ifelse(interval < 0, shift(RepeatsTotal_Qty, type = "lead") - shift(RepeatsLeft_Qty, type = "lead"), interval)]
dt_store_patient_drug_weekDiff = dt_store_patient_drug_week_5[, weekDiff := diffWeeks(shift(Dispense_Week, 1, type = "lead"), Dispense_Week) / interval_adjusted, by = c("Store_ID", "Patient_ID", "Drug_ID")]


# remove outliers ---------------------------------------------------------


# remove NAs
dt_store_patient_drug_weekDiff = dt_store_patient_drug_weekDiff[!is.na(weekDiff)]

# normal weekDiff
weekDiff_store_normal = quantile(dt_store_patient_drug_weekDiff$weekDiff, probs = seq(0, 1, .05), na.rm = T)
# 0%         5%        10%        15%        20% 
# -7776000.0        3.0        3.0        4.0        4.0 
# 25%        30%        35%        40%        45% 
# 4.0        4.0        4.0        5.0        5.0 
# 50%        55%        60%        65%        70% 
# 5.0        6.5        8.0        8.5        9.0 
# 75%        80%        85%        90%        95% 
# 10.0       15.5   259200.0   691200.0        Inf 
# 100% 
# Inf
dt_store_normal = dt_store_patient_drug_weekDiff[, all(weekDiff >= 1 & weekDiff <= weekDiff_store_normal[["80%"]]), by = .(Store_ID, Patient_ID, Drug_ID)]
dt_store_normal = dt_store_normal[V1==T]
dt_store_patient_drug_weekDiff_norm = merge(dt_store_normal, dt_store_patient_drug_weekDiff, by = c("Store_ID", "Patient_ID", "Drug_ID"))

# normal weekDiff by drug
 
# store level -------------------------------------------------------------

dt_store_drug_compliance = merge(dt_store_patient_drug_weekDiff_norm, dt_drug_freq_pop_norm, by = "Drug_ID")
dt_store_drug_compliance = merge(dt_store_drug_compliance, dt_store, by = "Store_ID")
dt_store_drug_meand_sd = dt_store_drug_compliance[,  .(meanDiff = mean(abs(weekDiff - med))
                              , sdDiff = sd(abs(weekDiff - med))), by = .(Store_ID)]

merge(dt_store_drug_meand_sd, dt_store)

dt_plot_store_compliance = merge(dt_store_drug_meand_sd, dt_store)
dt_plot_store_compliance[, Rural := as.numeric(postcode_store) - trunc(as.numeric(postcode_store) / 1000) * 1000]


ggplot(dt_plot_store_compliance, aes(x = meanDiff, y = sdDiff, color = postcode_store)) +
  geom_point(size = 5, alpha = .4) +
  scale_y_continuous(limits = c(0, 5)) +
  scale_x_continuous(limits = c(0, 5.5))

# nothing interesting about state
# nothing interesting about rural
# nothing interesting about banner
# nothing interesting about postcode


dt_plot_store_compliance[, .(mean(meanDiff)), by = IsBannerGroup]
