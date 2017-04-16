require(data.table)
require(magrittr)


# txn ---------------------------------------------------------------------

L = sort(list.files("../../data/MelbDatathon2017/Transactions/", full.names = T))
L = L[sample(1:50, 5)] # sample
dt_txn = lapply(L, fread) %>% rbindlist()


# atc ---------------------------------------------------------------------

dt_atc = fread("../../data/MelbDatathon2017/Lookups/ATC_LookUp.txt")


# illness -----------------------------------------------------------------

dt_ilness = fread("../../data/MelbDatathon2017/Lookups/ChronicIllness_LookUp.txt")


# drug --------------------------------------------------------------------

dt_drug = fread("../../data/MelbDatathon2017/Lookups/Drug_LookUp.txt")


# patient -----------------------------------------------------------------

dt_patient = fread("../../data/MelbDatathon2017/Lookups/patients.txt")


# store -------------------------------------------------------------------

dt_store = fread("../../data/MelbDatathon2017/Lookups/stores.csv")

