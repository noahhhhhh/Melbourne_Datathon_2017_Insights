require(ggplot2)

dt_drug_assoc = (dt_basket_drugs_pairs[, .N, by = MasterProductShortName])[order(-N)]

g = ggplot(data = dt_drug_assoc[1:10]
           , aes(x = reorder(MasterProductShortName, N)
                 , y = N)
           )
g = g + geom_bar(stat = "identity")

g = g + xlab("Drugs")
g = g + ggtitle("Drug Associations")
g = g + coord_flip()

g