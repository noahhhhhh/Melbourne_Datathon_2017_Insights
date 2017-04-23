# Melbourne_Datathon_2017_Insights
There are still plenty of days left for Kaggle, so let us all focus on the insights competition first.

## A higher level plan
Based on our discussion, it might be more efficient to **1)** split our work (first week) and **2)** then regroup and make one (maximum two) story for the pitch (second week).

### The first week
The first week would be **EDA** until we find something interesting. 
Below is a list of initial ideas we came up during the "standup". Let us generate our ideas within our responsible area for now, but if you have some interesting ideas which fall into other's group, do let all of us know. Also, please do not limit our brains with the list below, it is more about dividing ourselves into different areas so we can work more effeciently. Hopefully we will be able to find out something very interesting ASAP so all of us can jump into it and kick off the next steps.

- Customer (Ivan & Cat)
  - Loyalty segmentation
  - Store of choice
  - Descriptive stats on demographic
  - Shopper style
  - Big shopper
  - (Patient ID could help impute age?)
  - etc.
- Txn Behaviour (Noah)
  - Basket analysis: association rule / word2vec
    - drugs [done]
    - disease [done]
  - chord diagram for disease co-occurance [done]
  - chord diagram for disease + never seen again [done]
  - Shopping pattern for patients who got cured (potential best practice for other patients?)
  - etc.
- Disease (Michael)
  - Customer journey/Sankey chart on disease transition/Markov Chain [done, might need decoration later]
  - Condition analysis for Symptons/Ingredients vs. Disease
  - etc.
- Drug (Max)
  - Price elasticity (how sensitive is the sales corresponding to the price of products)
  - Product substitution (which drugs can be subtitutes for a drug)
  - etc.
  
  
### The second week [JUst realised we have one extra week!]
The second week (hopefully we could start this stage sooner) would be **story making**.
An agreed guideline is to make our story **easy to understand for general audience**, **engaging**, and **interesting/useful**. Try to avoid covering everything. Focusing on one or two things would be sufficient.

As discussed, we would like to jump into the **drug popularity (by doctors/patients/pharmacies/state) analysis**, while Max can help with digging into the sales analysis, by postcode, and competency analysis using HHI. Hopefully we could combine all these into one story :)

Regarding the drug popularity analysis, a high level overview is summarised as below:
  1. [**When and What**] Plotting the time series of the popularity of (the most common) drugs for each illness by prescribers, patients, pharmacies, or even states, respectively, to see if there are any change points where suddenly a drug becomes super popular (or become not popular at all).
  2. [**Why**] Based on these change points, we look for the news about that particular drug around that time, to find out why the change points happened. 
      - It could be because PBS suddenly remove a drug from its list, 
      - or could be driven by a particular reserch finding, 
      - or could simply because the manufacturer stopped producing it,
      - etc. 
      We then keep a list of this kind of changes points of different drugs and their associated reasons so later we could put a summary in our slides.
  3. [**How**] Having known the reasons which drive the change, we then look at how the doctors/patients/pharmacies/state react to the news.
      - Would there be some lags between the news and the prescription date, 
      - or patients suddenly missing from transaction since then,
      - or patients keep buying the old medicine regardless but achieved good result (how to measure good or bad?), 
      - or the sales become going down and how pharmacies dealt with it,
      - or some doctors don't follow the news and keep prescriping the drug for new patients,
      - etc.
  4. [**So What**] Given we know what's happened, the reasons driving the change, and how different parties react to such change, we then propose what actions we should take in response.
      - If the impact of the change is good, shall we propose a system that helps shorten the lag between news and the prescription date (i.e., allowing doctors to follow the findings of the new research and government announcements sooner)?
      - If the impact of the change turns out to be bad for patietns, we should let the government be aware of this.
      - **No matter what the reasons was, can we build some model to predict what the impact is (e.g., patients' txn behaviour, txns or sales of pharmacies, doctors' lag) after the change so that responsible parties can take actions sooner?**
      - If we can't find any reasons, it will be very interesting then.
      - etc.
