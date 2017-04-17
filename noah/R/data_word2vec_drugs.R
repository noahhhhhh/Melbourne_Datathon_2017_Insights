require(stringr)


# merge drug --------------------------------------------------------------

dt_txn_drug = merge(dt_txn, dt_drug, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)


# create txn id -----------------------------------------------------------

dt_txn_drug[, Transaction_ID := paste0(str_pad(Patient_ID, 6, side = "left", pad = "0")
                                       , "_"
                                       , str_pad(Store_ID, 4, side = "left", pad = "0")
                                       , "_"
                                       , as.character(Dispense_Week))]


# substring drug name -----------------------------------------------------

dt_txn_drug[, MasterProductShortName := sub(" .*", "", MasterProductFullName)]



# distinct ----------------------------------------------------------------

dt_txn_drug = dt_txn_drug[, c("Transaction_ID", "MasterProductShortName"), with = F]
dt_txn_drug = dt_txn_drug[order(MasterProductShortName)]
dt_txn_drug = dt_txn_drug[!duplicated(dt_txn_drug)]


# aggregate drugs ---------------------------------------------------------

dt_basket_drugs = aggregate(MasterProductShortName ~ Transaction_ID, data = dt_txn_drug, toString)
setDT(dt_basket_drugs)


# only include pairs ------------------------------------------------------

dt_basket_drugs_pairs = dt_basket_drugs[grepl(",", MasterProductShortName)]


# concatenate to text -----------------------------------------------------

vec_txt = paste0(gsub(" ", "", dt_basket_drugs_pairs$MasterProductShortName), collapse = ",")
write(vec_txt, file = "../../data/MelbDatathon2017/New/drugs.txt")
