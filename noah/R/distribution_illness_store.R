require(ggplot2)

ggplot(xx, aes(x = ChronicIllness, y = Perc)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_grid(StateCode ~ .)


