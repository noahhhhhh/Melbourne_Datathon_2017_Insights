source("R/load.R")

require(lubridate)
require(ggplot2)
require(RColorBrewer)

# remove duplicates -------------------------------------------------------


x = dt_txn[!duplicated(dt_txn)]


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

saveRDS(dt_drug_freq_pop_norm, "../../data/MelbDatathon2017/New/dt_drug_freq_pop_norm.rds")


# plot non-compliance level at drug level ---------------------------------

dt_plot_drug_freq_pop_norm = merge(dt_drug_freq_pop_norm, dt_drug, by.x = "Drug_ID", by.y = "MasterProductID")
ggplot(dt_plot_drug_freq_pop_norm[rankN <= 200], aes(x = rankN, y = mad, colour = EthicalCategoryName)) +
  geom_point(size = 4, alpha = .4, position = "jitter") +
  geom_hline(yintercept = 2, linetype = "dashed") +
  scale_color_brewer(palette = "Set1") +
  ggtitle("Non-Compliance Index for Top 200 Popular Drugs") +
  xlab("Popularity") +
  ylab("Non-Compliance Index") +
  theme_bw() +
  annotate("text", 25, 2.2, label = "Acceptable Compliance Level")

setorder(dt_plot_drug_freq_pop_norm, -pop)


# table top popular and compliant drugs not in PBS ------------------------

# all drugs
View(dt_plot_drug_freq_pop_norm[rankN <= 250 & mad <= 2 & EthicalCategoryName == "ETHICAL NON PBS", .(Drug_ID, rankN, pop, mad, MasterProductFullName)])

# chronic illness drugs
dt_plot_chronicDrug_freq_pop_norm = merge(dt_plot_drug_freq_pop_norm, dt_ilness, by.x = c("Drug_ID", "MasterProductFullName"), by.y = c("MasterProductID", "MasterProductFullName"))
View(dt_plot_chronicDrug_freq_pop_norm[rankN <= 250 & mad <= 2 & EthicalCategoryName == "ETHICAL NON PBS", .(Drug_ID, rankN, pop, mad, MasterProductFullName)])


# drug by brand -----------------------------------------------------------

dt_plot_drug_freq_pop_norm[, Branded := sapply(EthicalSubCategoryName, function(x){tail(strsplit(x, split=" ")[[1]], 1)})]

# all drugs
dt_plot_bar_branded_compliance = dt_plot_drug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop)), by = "Branded"]
# Branded      mad     pop
# 1:       Generic 1.680371 8286240
# 2: Substitutable 2.087887 7810880
# 3:       Branded 2.161450 2470285
# 4:  Sub-Category 2.114373   82273
# 5:    Applicable 0.000000       4

ggplot(dt_plot_bar_branded_compliance[pop > 100000], aes(x = Branded, y = mad, fill = Branded)) +
  geom_bar(stat = "identity") +
  ggtitle("Non-Compliance Index by Brand") +
  xlab("Branded") +
  ylab("Non-Compliance Index")

# chronic illness drugs
dt_plot_chronicDrug_freq_pop_norm[, Branded := sapply(EthicalSubCategoryName, function(x){tail(strsplit(x, split=" ")[[1]], 1)})]
dt_plot_bar_chronic_branded_compliance = dt_plot_chronicDrug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop)), by = "Branded"]
# Branded      mad     pop
# 1:       Generic 1.550460 4357385
# 2: Substitutable 1.796677 4283052
# 3:       Branded 1.947905 1790441

ggplot(dt_plot_bar_chronic_branded_compliance[pop > 100000], aes(x = Branded, y = mad, fill = Branded)) +
  geom_bar(stat = "identity") +
  ggtitle("Non-Compliance Index by Brand") +
  xlab("Branded") +
  ylab("Non-Compliance Index")

# brand name
dt_brand_name = dt_plot_drug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop), .N), by = "BrandName"]
dt_brand_name[, rankN := frank(-pop, ties.method = "first")]
setorder(dt_brand_name, mad)
dt_brand_name[rankN <= 100]
plot(dt_brand_name[rankN <= 100]$rankN, dt_brand_name[rankN <= 100]$mad)
  # chronic
dt_brand_name = dt_plot_chronicDrug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop), .N), by = "BrandName"]
dt_brand_name[, rankN := frank(-pop, ties.method = "first")]
setorder(dt_brand_name, mad)
dt_brand_name[rankN <= 50]

# manufacturer
dt_manu_name = dt_plot_drug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop), .N), by = "ManufacturerName"]
dt_manu_name[, rankN := frank(-pop, ties.method = "first")]
setorder(dt_manu_name, mad)
dt_manu_name[rankN <= 15]
plot(dt_manu_name[rankN <= 15]$rankN, dt_manu_name[rankN <= 15]$mad)
  # chronic
dt_manu_name = dt_plot_chronicDrug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop), .N), by = "ManufacturerName"]
dt_manu_name[, rankN := frank(-pop, ties.method = "first")]
setorder(dt_manu_name, mad)
dt_manu_name[rankN <= 10]

# generic ingredient
dt_ingredient = dt_plot_drug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop), .N), by = "GenericIngredientName"]
dt_ingredient[, rankN := frank(-pop, ties.method = "first")]
setorder(dt_ingredient, mad)
dt_ingredient[rankN <= 100]
plot(dt_ingredient[rankN <= 100]$pop, dt_ingredient[rankN <= 100]$mad)
  # chronic
dt_ingredient = dt_plot_chronicDrug_freq_pop_norm[, .(mad = mean(mad), pop = sum(pop), .N), by = "GenericIngredientName"]
dt_ingredient[, rankN := frank(-pop, ties.method = "first")]
setorder(dt_ingredient, mad)
dt_ingredient[rankN <= 10]

# atc
dt_atc_drug = merge(dt_plot_drug_freq_pop_norm, dt_atc[, .(ATCLevel1Code, ATCLevel1Name)][!duplicated(dt_atc[, .(ATCLevel1Code, ATCLevel1Name)])], by = c("ATCLevel1Code"))
dt_atc_drug = merge(dt_atc_drug, dt_atc[, .(ATCLevel2Code, ATCLevel2Name)][!duplicated(dt_atc[, .(ATCLevel2Code, ATCLevel2Name)])], by = c("ATCLevel2Code"))
dt_atc_drug = merge(dt_atc_drug, dt_atc[, .(ATCLevel3Code, ATCLevel3Name)][!duplicated(dt_atc[, .(ATCLevel3Code, ATCLevel3Name)])], by = c("ATCLevel3Code"))
dt_atc_drug = merge(dt_atc_drug, dt_atc[, .(ATCLevel4Code, ATCLevel4Name)][!duplicated(dt_atc[, .(ATCLevel4Code, ATCLevel4Name)])], by = c("ATCLevel4Code"))
dt_atc_drug = merge(dt_atc_drug, dt_atc[, .(ATCLevel5Code, ATCLevel5Name)][!duplicated(dt_atc[, .(ATCLevel5Code, ATCLevel5Name)])], by = c("ATCLevel5Code"))

dt_atc_drug = dt_atc_drug[, .(mad = mean(mad), pop = sum(pop), .N), by = "ATCLevel2Name"]

dt_atc_drug[, rankN := frank(-pop, ties.method = "first")]
setorder(dt_atc_drug, mad)
ggplot(dt_atc_drug, aes(x = ATCLevel2Name, y = mad, fill = ATCLevel2Name)) +
  geom_bar(stat = "identity") +
  # scale_fill_brewer(palette = "Paired") +
  ggtitle("Non-Compliance Index by ATCLevel2Name") +
  xlab("Branded") +
  ylab("Non-Compliance Index")
  

