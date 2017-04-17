require(stringr)

dt_focus_year = dt_txn[Dispense_Week < as.Date("2016-01-01") & Dispense_Week >= as.Date("2015-01-01")]

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


# aggregate ilnesss ---------------------------------------------------------

dt_basket_patient_ilnesss = aggregate(ChronicIllness ~ Patient_ID, data = dt_patient_ilness, toString)
setDT(dt_basket_patient_ilnesss)


# only include pairs ------------------------------------------------------

dt_basket_patient_ilnesss_pairs = dt_basket_patient_ilnesss[grepl(",", ChronicIllness)]
