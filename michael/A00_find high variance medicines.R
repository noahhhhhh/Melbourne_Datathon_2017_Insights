## A quick and basic way to find changepoints 
# This script actually only looks for variance currently

# load libraries
library(data.table)
library(ggplot2)
library(magrittr)

# import data
L <- sort(list.files("D:/datathon2017/MelbDatathon2017/Transactions/", full.names = TRUE))

txns <- lapply(L[1:10], fread) %>% rbindlist() %>% unique()

prescriptions <- txns[ , .N , by = .(Drug_ID, Prescription_Week)]

prescriptions[ , Prescription_Week := as.IDate(Prescription_Week)]

# fill missing weeks with a zero
date_ranges <- prescriptions[ , .(Prescription_Week = 
                                    seq.Date( min(Prescription_Week),
                                              max(Prescription_Week),
                                              by = 'week'),
                                  N = 0) , 
                              by = Drug_ID]

fill0s <- date_ranges[ !prescriptions , on = c("Drug_ID", "Prescription_Week")]
fill0s[ , Prescription_Week := as.IDate(Prescription_Week) ]

prescriptions <- rbindlist(list(prescriptions, fill0s))

# calculate variance and coefficient of variation (the latter is scaleless)
prescriptions[ , var := var(N) , by = Drug_ID]
prescriptions[ , coef.var := sd(N)/mean(N) , by = Drug_ID]

prescriptions[ , Nweeks := diff(range(Prescription_Week))/7 , by = Drug_ID]

# coefficient of variation
plot.prescribed.coefvar <- copy(prescriptions)
plot.prescribed.coefvar[ var > 20, rank := frank(-coef.var, ties.method = "dense")]

ggplot(plot.prescribed.coefvar[ rank <= 30])+
  geom_line(aes(x = Prescription_Week, y = N)) + 
  facet_grid(Drug_ID ~., scales = "free", space = "free") + 
  theme(strip.text.y = element_text(angle = 0))

# variance
plot.prescribed.var <- copy(prescriptions)
plot.prescribed.var[ var > 20, rank := frank(-var, ties.method = "dense")]

ggplot(plot.prescribed.var[ rank <= 30])+
  geom_line(aes(x = Prescription_Week, y = N)) + 
  facet_grid(Drug_ID ~., scales = "free", space = "free") + 
  theme(strip.text.y = element_text(angle = 0))


