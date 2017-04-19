require(stringr)
require(dplyr)
require(lubridate)

source("R/load.R")

dt_focus_year = dt_txn[Prescription_Week < as.Date("2016-01-01") & Prescription_Week >= as.Date("2010-01-01")]


# merge ilness --------------------------------------------------------------

dt_patient_ilness = merge(dt_focus_year, dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)


# year --------------------------------------------------------------------

dt_patient_ilness[, Year := year(Prescription_Week)]


# aggregate by patient, year, illness -------------------------------------

dt_patient_illness_year = dt_patient_ilness[, .N, by = c("Patient_ID", "Year", "ChronicIllness")]
dt_patient_illness_year = dt_patient_illness_year[!is.na(ChronicIllness)]


# COPD --------------------------------------------------------------------

dt_patient_illness_year[, ChronicIllness := ifelse(ChronicIllness == "Chronic Obstructive Pulmonary Disease (COPD)"
                                             , "COPD"
                                             , ChronicIllness)]



# get the most frequent disease by patient and year -----------------------

setorderv(dt_patient_illness_year, c("Patient_ID", "Year", "N"))
dt_patient_illness_year_max = dt_patient_illness_year[dt_patient_illness_year[, .I[which.max(N)], by = c("Patient_ID", "Year")]$V1]
dt_patient_illness_year_max[, ChronicIllness := paste0(Year, "_", ChronicIllness)]


# lead --------------------------------------------------------------------

dt_patient_illness_year_max[, ChronicIllness_Next := shift(.SD, type = "lead"), by = Patient_ID, .SDcols = "ChronicIllness"]


# ready for sankey --------------------------------------------------------

dt_patient_illness_year_max = dt_patient_illness_year_max[, c("ChronicIllness", "ChronicIllness_Next"), with = F]
setnames(dt_patient_illness_year_max, names(dt_patient_illness_year_max), c("source", "target"))

dt_patient_illness_year_transition = dt_patient_illness_year_max[, .N, by = c("source", "target")]
setnames(dt_patient_illness_year_transition, names(dt_patient_illness_year_transition), c("source", "target", "value"))
dt_patient_illness_year_transition = dt_patient_illness_year_transition[!is.na(target)]
