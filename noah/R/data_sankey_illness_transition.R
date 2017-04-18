require(stringr)
require(dplyr)

source("R/load.R")

dt_focus_year = dt_txn[Dispense_Week < as.Date("2015-01-01")]


# merge ilness --------------------------------------------------------------

dt_patient_ilness = merge(dt_focus_year, dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)


# distinct ----------------------------------------------------------------

dt_patient_ilness = dt_patient_ilness[, c("Patient_ID", "ChronicIllness", "Prescription_Week"), with = F]
setorderv(dt_patient_ilness, c("Patient_ID", "Prescription_Week"))
dt_patient_ilness = dt_patient_ilness[!duplicated(dt_patient_ilness)]
dt_patient_ilness = dt_patient_ilness[!is.na(ChronicIllness)]

# later year --------------------------------------------------------------

dt_later_year = dt_txn[Dispense_Week >= as.Date("2015-01-01") & Dispense_Week < as.Date("2016-01-01")]
dt_later_year = dt_later_year[, c("Patient_ID"), with = F]
dt_later_year = dt_later_year[!duplicated(dt_later_year)]
dt_later_year[, NeverSeenAgain := 0]
dt_patient_ilness_neverseenagain = merge(dt_patient_ilness, dt_later_year, by = "Patient_ID", all.x = T)
dt_patient_ilness_neverseenagain[, NeverSeenAgain := ifelse(is.na(NeverSeenAgain), 1, 0)]
dt_patient_neverseenagain = data.table(Patient_ID = unique(dt_patient_ilness_neverseenagain[NeverSeenAgain == 1]$Patient_ID)
                                       , ChronicIllness = "NeverSeenAgain")

dt_patient_ilness = rbind(dt_patient_ilness[, c("Patient_ID", "ChronicIllness"), with = F], dt_patient_neverseenagain)

# COPD --------------------------------------------------------------------

dt_patient_ilness[, ChronicIllness := ifelse(ChronicIllness == "Chronic Obstructive Pulmonary Disease (COPD)"
                                             , "COPD"
                                             , ChronicIllness)]


# lead --------------------------------------------------------------------

dt_patient_ilness[, target := shift(.SD, type = "lead"), by = Patient_ID, .SDcols = "ChronicIllness"]


# ready for sankey --------------------------------------------------------

dt_patient_ilness[, source := ChronicIllness]
dt_patient_ilness = dt_patient_ilness[source != target]

dt_illness_transition = dt_patient_ilness[, .N, by = c("target", "source")]
dt_illness_transition = dt_illness_transition[, c("source", "target", "N"), with = F]
setnames(dt_illness_transition, names(dt_illness_transition), c("source", "target", "value"))
