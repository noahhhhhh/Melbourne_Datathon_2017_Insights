require(stringr)

dt_focus_year = dt_txn[Dispense_Week < as.Date("2016-01-01")]


# merge ilness --------------------------------------------------------------

dt_patient_ilness = merge(dt_focus_year, dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)


# create txn id -----------------------------------------------------------

# dt_patient_ilness[, Transaction_ID := paste0(str_pad(Patient_ID, 6, side = "left", pad = "0")
#                                          , "_"
#                                          , str_pad(Store_ID, 4, side = "left", pad = "0")
#                                          , "_"
#                                          , as.character(Dispense_Week))]


# substring ilness name -----------------------------------------------------

# dt_patient_ilness[, MasterProductShortName := sub(" .*", "", MasterProductFullName)]



# distinct ----------------------------------------------------------------

dt_patient_ilness = dt_patient_ilness[, c("Patient_ID", "ChronicIllness"), with = F]
dt_patient_ilness = dt_patient_ilness[order(ChronicIllness)]
dt_patient_ilness = dt_patient_ilness[!duplicated(dt_patient_ilness)]
dt_patient_ilness = dt_patient_ilness[!is.na(ChronicIllness)]


# later year --------------------------------------------------------------

dt_later_year = dt_txn[Dispense_Week >= as.Date("2016-01-01")]
dt_later_year = dt_later_year[, c("Patient_ID"), with = F]
dt_later_year = dt_later_year[!duplicated(dt_later_year)]
dt_later_year[, NeverSeenAgain := 0]
dt_patient_ilness_neverseenagain = merge(dt_patient_ilness, dt_later_year, by = "Patient_ID", all.x = T)
dt_patient_ilness_neverseenagain[, NeverSeenAgain := ifelse(is.na(NeverSeenAgain), 1, 0)]
dt_patient_neverseenagain = data.table(Patient_ID = unique(dt_patient_ilness_neverseenagain[NeverSeenAgain == 1]$Patient_ID)
                                       , ChronicIllness = "NeverSeenAgain")

dt_patient_ilness = rbind(dt_patient_ilness, dt_patient_neverseenagain)


# COPD --------------------------------------------------------------------

dt_patient_ilness[, ChronicIllness := ifelse(ChronicIllness == "Chronic Obstructive Pulmonary Disease (COPD)"
                                             , "COPD"
                                             , ChronicIllness)]

# aggregate ilnesss ---------------------------------------------------------

dt_basket_patient_ilnesss = aggregate(ChronicIllness ~ Patient_ID, data = dt_patient_ilness, toString)
setDT(dt_basket_patient_ilnesss)


# only include pairs ------------------------------------------------------

# dt_basket_patient_ilnesss_pairs = dt_basket_patient_ilnesss[grepl(",", ChronicIllness)]
