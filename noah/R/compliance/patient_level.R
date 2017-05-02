rm(list = ls()); gc(); cat("\014")

source("R/load.R")

# remove duplicates -------------------------------------------------------


x = dt_txn[!duplicated(dt_txn)]


# data patient, drug, week ------------------------------------------------


dt_patient_drug_week = x[, .(Store_ID, Patient_ID, Drug_ID, Dispense_Week, RepeatsTotal_Qty, RepeatsLeft_Qty, Script_Qty)]

setorderv(dt_patient_drug_week, c("Store_ID", "Patient_ID", "Drug_ID", "Dispense_Week"))


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

# # normal weekDiff by drug
# dt_drug_weekDiff_normal = dt_patient_drug_weekDiff_norm[, .(WD_q05 = quantile(weekDiff, probs = c(.05), na.rm = T)
#                                                             , WD_q85 = quantile(weekDiff, probs = c(.85), na.rm = T)), by = Drug_ID]
# 
# # normal popularity by drug
# dt_drug_pop_normal = dt_patient_drug_weekDiff_norm[, .(N_q05 = quantile(N, probs = c(.05), na.rm = T)
#                                                        , N_q85 = quantile(N, probs = c(.85), na.rm = T)), by = Drug_ID]
# 


# patient level -----------------------------------------------------------


dt_patient_drug_weekDiff_norm


# read drug level ipi -----------------------------------------------------

dt_drug_freq_pop_norm = readRDS("../../data/MelbDatathon2017/New/dt_drug_freq_pop_norm.rds")



# merge patient and drug --------------------------------------------------


dt_patient_drug_compliance = merge(dt_patient_drug_weekDiff_norm[, .(Store_ID, Patient_ID, Drug_ID, weekDiff, Dispense_Week)], dt_drug_freq_pop_norm[, .(Drug_ID, med)], by = "Drug_ID")
dt_patient_drug_compliance = dt_patient_drug_compliance[, .(Store_ID, Patient_ID, Drug_ID, Dispense_Week, weekDiff, med)]
setnames(dt_patient_drug_compliance, c("Store_ID", "Patient_ID", "Drug_ID", "Dispense_Week", "weekDiff", "IPI"))

saveRDS(dt_patient_drug_compliance, "../../data/MelbDatathon2017/New/dt_patient_drug_compliance.rds")


# patient -----------------------------------------------------------------


dt_patient_txn_N = x[, .N, by = Patient_ID]
setnames(dt_patient_txn_N, c("Patient_ID", "N_TXNs"))
dt_patietn_drug_N = x[, .N, by = .(Patient_ID, Drug_ID)][, .N, by = Patient_ID]
setnames(dt_patietn_drug_N, c("Patient_ID", "N_Drugs"))

dt_patietn_illness = merge(x[, .N, by = .(Patient_ID, Drug_ID)], dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID")
dt_patietn_illness_N = dt_patietn_illness[, .N, by = .(Patient_ID, ChronicIllness)][, .N, by = Patient_ID]
setnames(dt_patietn_illness_N, c("Patient_ID", "N_Illness"))


# merge patient and patient drug compliance -------------------------------

dt_patient_compliance = dt_patient_drug_compliance[, .(Non_Compliance_Index = sd(abs(weekDiff - IPI))), by = Patient_ID]
dt_patient_compliance_more = merge(merge(merge(dt_patient_compliance, dt_patient_txn_N, by = "Patient_ID")
                                         , dt_patietn_drug_N, by = "Patient_ID")
                                   , dt_patietn_illness_N, by = "Patient_ID")



# txn vs. non compliance index
quant_nonComplianceIndex = quantile(dt_patient_compliance_more$Non_Compliance_Index, seq(0, 1, .1))
quant_N_TXNs = quantile(dt_patient_compliance_more$N_TXNs, seq(0, 1, .1))
ggplot(dt_patient_compliance_more[Non_Compliance_Index < quant_nonComplianceIndex[["90%"]] & 
                                    N_TXNs <= quant_N_TXNs[["90%"]] &
                                    N_TXNs >= quant_N_TXNs[["10%"]]]
       , aes(x = N_TXNs, y = Non_Compliance_Index, colour = Non_Compliance_Index)) +
  geom_point()

# drug vs. non compliance index
ggplot(dt_patient_compliance_more[Non_Compliance_Index < quant_nonComplianceIndex[["80%"]] & 
                                    N_TXNs <= quant_N_TXNs[["90%"]] &
                                    N_TXNs >=   quant_N_TXNs[["10%"]]]
       , aes(x = as.factor(N_Drugs), y = Non_Compliance_Index)) +
  geom_boxplot()

# illness vs. non compliance index
ggplot(dt_patient_compliance_more[Non_Compliance_Index < quant_nonComplianceIndex[["80%"]] & 
                                    N_TXNs <= quant_N_TXNs[["90%"]] &
                                    N_TXNs >= quant_N_TXNs[["10%"]]]
       , aes(x = as.factor(N_Illness), y = Non_Compliance_Index)) +
  geom_boxplot()

# illness again
merge(dt_patient_drug_compliance, dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID")[, .(Non_Compliance_Index = sd(abs(weekDiff - IPI))), by = ChronicIllness]

