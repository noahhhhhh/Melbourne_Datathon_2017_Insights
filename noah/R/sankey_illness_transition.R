# sankey chart using d3 plugin for rCharts and the igraph library

require(rCharts)

x = dt_illness_transition[source == "Immunology"]
value_sum = sum(x$value)
x[, value := (value / value_sum) * 100]

# now we plot
sankeyPlot <- rCharts$new()
sankeyPlot$setLib('http://timelyportfolio.github.io/rCharts_d3_sankey/libraries/widgets/d3_sankey')
sankeyPlot$set(
  data = x,
  nodeWidth = 15,
  nodePadding = 15,
  layout = 32,
  width = 800,
  height = 600
)

sankeyPlot$setTemplate(
  afterScript = "
  <script>
  d3.selectAll('#{{ chartId }} svg text')
  .style('font-size', '14')
  </script>
  ")

sankeyPlot
