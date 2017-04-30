rm(list = ls()); gc(); cat("\014");

require(data.table)
require(magrittr)


# txn ---------------------------------------------------------------------

L = sort(list.files("../../data/MelbDatathon2017/Transactions/", full.names = T))
L_Miss = sort(list.files("../../data/MelbDatathon2017/MISSING_TRANSACTIONS/", full.names = T))

L = c(L, L_Miss)
# L = L[sample(1:50, 5)] # sample

dt_txn = lapply(L, fread) %>% rbindlist()
dt_txn[, Dispense_Week := as.Date(Dispense_Week)]
dt_txn[, Prescription_Week := as.Date(Prescription_Week)]

# atc ---------------------------------------------------------------------

dt_atc = fread("../../data/MelbDatathon2017/Lookups/ATC_LookUp.txt")


# illness -----------------------------------------------------------------

dt_ilness = fread("../../data/MelbDatathon2017/Lookups/ChronicIllness_LookUp.txt")
dt_ilness[, !c("MasterProductFullName"), with = F]

# drug --------------------------------------------------------------------

dt_drug = fread("../../data/MelbDatathon2017/Lookups/Drug_LookUp.txt")


# patient -----------------------------------------------------------------

dt_patient = fread("../../data/MelbDatathon2017/Lookups/patients.txt")
setnames(dt_patient, c("Patient_ID", "gender", "year_of_birth", "postcode_patient"))

# store -------------------------------------------------------------------

dt_store = fread("../../data/MelbDatathon2017/Lookups/stores.csv")
setnames(dt_store, names(dt_store), c("Store_ID", "StateCode", "postcode_store", "IsBannerGroup"))

# merge -------------------------------------------------------------------
# 
# x = merge(dt_txn, dt_drug, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)
# x = merge(x, dt_store, by = "Store_ID", all.x = T)
# x = merge(x, dt_patient, by = "Patient_ID", all.x = T)
# x = merge(x, dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)
