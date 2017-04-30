# Compliance
- Remove duplicates
- Calculate the purhcase interval at a Patient_ID, Drug level.
  (*Only include the drug which a patient has purhcased more than 5 times*)
  - The interval considered the pack size and repeats left, so the result should be intervals for standard pack-sized drugs
- Remove interval outliers
  - Some intervals are quite big, e.g., 2 purchases have a gap of 3 years.
  - Using .05 and .85 quantile
- Calculate the median of intervals at a Drug level
  - This is to get the standard interval for a standard pack-sized drug
- Calculate the MAD (Median Absolute Deviation) at a Drug level
  - Treat this as the **compliance** level for a drug, the higher the MAD is, the lower compliance level the drug is

## Ideas 
*(All points below nneds to consider the sample size, avoid small sample size)*
- Calculate the compliance level at an **illness level**
  (*Remoe 2016 and forward as diabetes patients are missing*)
  - which illness has the highest/lowest compliance level
- Calculate the compliance level at a **store level**
  - IsBannerGroup
  - State
  - postcode
 - Calculate the compliance level at a more detailed **drug level**
  - BrandName
  - EthicalCategoryName
  - EthicalSubCategoryName
  - ManufacturerName
  - GenericIngredientName
  - ATCLevel
- Calculate the compliance level at a **patient level**
  - postcode
  - patient who shop more
  - patient who has 1, 2, 3, ..., illnesses
  - patient who shop more but spend less
- Calculate the compliance level at a **prescriber level**
- Calculate the compliance level over time
  - a patient from smaller no. of illness to larger no. of illness
  - month
  - year
