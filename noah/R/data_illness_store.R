x = merge(dt_txn, dt_ilness, by.x = "Drug_ID", by.y = "MasterProductID", all.x = T)
x = merge(x, dt_store, by.x = "Store_ID", by.y = "Store_ID", all.x = T)

xx = x[, .N, by = c("Patient_ID", "StateCode", "ChronicIllness")][order(Patient_ID)]

xx = xx[!is.na(ChronicIllness)]

xx = xx[, .N, by = c("StateCode", "ChronicIllness")]

xx[, ChronicIllness := ifelse(ChronicIllness == "Chronic Obstructive Pulmonary Disease (COPD)"
                                             , "COPD"
                                             , ChronicIllness)]

xx[, SUM := sum(N), by = c("StateCode")]
xx[, Perc := N / SUM]
