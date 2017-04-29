dt_txn[RepeatsLeft_Qty == 2]

table(dt_txn$RepeatsLeft_Qty)
table(dt_txn$RepeatsTotal_Qty)

setkeyv(dt_txn, c("Prescriber_ID", "Drug_ID", "Prescription_Week"))
dt_txn[Prescriber_ID == 35480 & Drug_ID == 9302 & Prescription_Week == as.Date("2011-02-20")]

setkeyv(dt_txn, c("Patient_ID", "Prescription_Week"))
View(dt_txn[Patient_ID == 268033])

x = dt_txn[RepeatsLeft_Qty + Dispensed_Qty != RepeatsTotal_Qty]$SourceSystem_Code

x[Script_Qty != Dispensed_Qty]

dt_txn[SourceSystem_Code == "F"][Script_Qty == Dispensed_Qty][Script_Qty == 30]
table(dt_txn[SourceSystem_Code == "F"][Script_Qty != Dispensed_Qty]$Script_Qty)
dt_txn[SourceSystem_Code == "F"][Script_Qty != Dispensed_Qty][Script_Qty == 2]

# 90% of times RepeatsLeft_Qty + Dispensed_Qty == RepeatsTotal_Qty
# there is no RepeatsLeft_Qty < 2