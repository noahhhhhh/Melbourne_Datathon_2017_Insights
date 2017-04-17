require(ggplot2)

dt_ilness_assoc = (dt_basket_ilnesss_pairs[, .N, by = ChronicIllness])[order(-N)]

g = ggplot(data = dt_ilness_assoc[1:10]
           , aes(x = reorder(ChronicIllness, N)
                 , y = N)
)
g = g + geom_bar(stat = "identity")

g = g + xlab("Illness")
g = g + ggtitle("Illness Associations")
g = g + coord_flip()

g