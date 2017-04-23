require(networkD3)
require(data.table)

source("R/data_sankey_illness_transition.R")


# nodes -------------------------------------------------------------------


dt_nodes = dt_illness_transition[, c("target", "value"), with = F]
dt_nodes[, size := sum(value), by = target]
dt_nodes = dt_nodes[, c("target", "size"), with = F]
dt_nodes = dt_nodes[!duplicated(dt_nodes)]
dt_nodes[, group := 0:(nrow(dt_nodes) - 1)]

size_sum = sum(dt_nodes$size)
dt_nodes[, size := (size / size_sum) * 100]
setnames(dt_nodes, names(dt_nodes), c("name", "size", "group"))

# links -------------------------------------------------------------------


dt_links = merge(dt_illness_transition, dt_nodes, by.x = "source", by.y = "name")
dt_links = dt_links[, c("group", "target", "value"), with = F]
setnames(dt_links, names(dt_links), c("source", "target", "value"))

dt_links = merge(dt_links, dt_nodes, by.x = "target", by.y = "name")
dt_links = dt_links[, c("source", "group", "value"), with = F]
setnames(dt_links, names(dt_links), c("source", "target", "value"))

value_sum = sum(dt_links$value)
dt_links[, value := (value / value_sum) * 10]

# network -----------------------------------------------------------------

forceNetwork(Links = dt_links, Nodes = dt_nodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name", Nodesize = "size",
             Group = "group", opacity = 1, zoom = T, legend = T, arrows = T)