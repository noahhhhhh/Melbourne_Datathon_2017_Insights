x = dt_txn[, .N, by = c("Patient_ID", "Store_ID")][, .N, by = "Patient_ID"]
hist(x$N)

summary(x$N)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   1.000   2.000   2.369   3.000  26.000 