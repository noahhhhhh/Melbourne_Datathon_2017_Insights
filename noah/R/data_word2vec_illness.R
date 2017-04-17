require(stringr)


# merge ilness --------------------------------------------------------------

dt_txn_ilness = merge(dt_txn, dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)


# create txn id -----------------------------------------------------------

dt_txn_ilness[, Transaction_ID := paste0(str_pad(Patient_ID, 6, side = "left", pad = "0")
                                       , "_"
                                       , str_pad(Store_ID, 4, side = "left", pad = "0")
                                       , "_"
                                       , as.character(Dispense_Week))]


# substring ilness name -----------------------------------------------------

# dt_txn_ilness[, MasterProductShortName := sub(" .*", "", MasterProductFullName)]



# distinct ----------------------------------------------------------------

dt_txn_ilness = dt_txn_ilness[, c("Transaction_ID", "ChronicIllness"), with = F]
dt_txn_ilness = dt_txn_ilness[order(ChronicIllness)]
dt_txn_ilness = dt_txn_ilness[!duplicated(dt_txn_ilness)]


# aggregate ilnesss ---------------------------------------------------------

dt_basket_ilnesss = aggregate(ChronicIllness ~ Transaction_ID, data = dt_txn_ilness, toString)
setDT(dt_basket_ilnesss)


# only include pairs ------------------------------------------------------

dt_basket_ilnesss_pairs = dt_basket_ilnesss[grepl(",", ChronicIllness)]


# concatenate to text -----------------------------------------------------

vec_txt = paste0(gsub(" ", "", dt_basket_ilnesss_pairs$ChronicIllness), collapse = ",")
write(vec_txt, file = "../../data/MelbDatathon2017/New/ilnesss.txt")
