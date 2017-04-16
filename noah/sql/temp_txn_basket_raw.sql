select
distinct
right(RTRIM('000000' + cast(patient_id as nchar(6))), 6) + '_' + right(RTRIM('0000' + cast(store_id as nchar(4))), 4) + '_' + cast(dispense_week as nchar(10)) as ID
, Substring(b.MasterProductFullName, 1, CharIndex( ' ', b.MasterProductFullName) - 1) as Name
, c.ChronicIllness
into temp_txn_basket_raw
from
transactions a
left join drug_lookup b
on a.Drug_ID = b.MasterProductID
and a.Drug_Code = b.MasterProductCode
left join ChronicIllness_LookUp c
on a.Drug_ID = c.MasterProductID