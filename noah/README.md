# How to calc Non-Compliance Index
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
  - Treat this as the **compliance** index for a drug, the higher the MAD is, the lower compliance level the drug is

## Findings 
*(All points below nneds to consider the sample size, avoid small sample size)*
- **illness level** [Done]
  (*Remoe 2016 and forward as diabetes patients are missing*)
  - which illness has the highest/lowest compliance level
    - Hypertension is the illness with the lowest non-compliance index (used sd of drug non-compliance index)
    - Diabetes is the most non-compliant illness!? see screenshot
      - Non-Compliance Index by ChronicIllness
- **store level** [Done]
  - IsBannerGroup
    - nothing interesting
  - State
    - nothing interesting
  - postcode
    - nothing interesting
- **drug level** [Done]
  - EthicalCategoryName (Branded)
    - Generic drugs have the lowest non-compliance level, followed by Substitutable and Branded. See plots:
      - Non-Compliance Index by Brand
      - Non-Compliance Index by Brand (Chronic Illness Drugs)
  - EthicalSubCategoryName (PBS)
    - Majority of drugs which are most popular and compliant are covered by PBS, except a few. 
      - **ATORVASTATIN, MONOPLUS, PROTOS SACH are extremetly popular medicines and with very low non-compliance level, BUT they are not in PBS. See plots**:
        - Non-Compliance Index for Top 200 Popular Drugs
        - Top 5 Most Popular and Comliant Chronical Illness Drugs which are not in the PBS
        - Top 10 Most Popular and Comliant Drugs which are not in the PBS
  - BrandName
    - Good ones
      - COVERSYL PLUS: popularity top 30, non-compliance index = 0.741
      - XARELTO: popularity top 49, non-compliance index = 0.926
    - Bad ones
      - MINAX: popularity top 46, non-compliance index = 3.71
      - ASMOL CFC FREE: popularity top 47, non-compliance index = 3.71
      - MINIPRESS: popularity top 91, non-compliance index = 3.21
  - ManufacturerName
    - nothing interesting
  - GenericIngredientName
    - Good ones
      - RIVAROXABAN: popularity top 55, non-compliance index = 0.92
      - RALOXIFENE: popularity top 94, non-compliance index = 1.06
    - Bad ones
      - PREDNISOLONE: popularity top 75, non-compliance index = 3.82
      - SPIRONOLACTONE: popularity top 90, non-compliance index = 5.19
  - ATCLevel
    - nothing interesting
- **patient level**
  - postcode
  - patient who shop more
  - patient who has 1, 2, 3, ..., illnesses
  - patient who shop more but spend less
- **prescriber level** [Done]
  - Prescriber 1638 has the lowest non-compliance index (1.313) within top 100 most popular prescribers
    - 1.313 means only 1.313 week deviation from the standard drug frequency
- **time level**
  - a patient from smaller no. of illness to larger no. of illness
  - month
  - year
