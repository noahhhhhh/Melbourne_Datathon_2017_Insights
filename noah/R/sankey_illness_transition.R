# sankey chart using d3 plugin for rCharts and the igraph library

require(rCharts)
require(RColorBrewer)

# data
x = dt_patient_illness_year_transition
value_sum = sum(x$value)
x[, value := (value / value_sum) * 100]
setorderv(x, c("source", "value"))

# color
change_node_colors <- function(widget, colors = NULL, json = NULL) {
  if (!class(widget) == "rCharts") stop("The widget must be an rCharts widget.")
  if (!require(gplots, quietly = TRUE)) stop("The package gplots is required, but is not installed.")
  if (is.null(colors) & is.null(json)) stop("colors and json cannot both be empty; one of them must be defined.")
  
  if (!is.null(colors)) {
    entities <- unique(c(widget$params$data$source, widget$params$data$target))
    entities = entities[order(entities)]
    # colors <- sapply(colors, function(color) col2hex(color))
    # If there are less colors than there are entities, then randomly assign colors
    # If there are enough colors for each entity, then assign in order
    if (length(colors) != length(entities)) {
      colors <- sample(colors, length(entities), replace = TRUE)
    }
    json = vector()
    for (i in 1:length(entities)) {
      json <- c(json, sprintf('"%s": "%s"', entities[i], colors[i]))
    }
    json <- paste(json, collapse = ", ")
    json <- sprintf("{%s}", json)
  } else {
    warning("If your plot didn't generate properly, it may be because you did not use #FFFFFF style coding for your colors.")
  }
  
  after_script <- sprintf("
<script>
                          var colors = JSON.parse('%s');
                          d3.selectAll('#{{ chartId }} svg .node rect')
                          .style('fill', function(d) { return '#999999' })
                          .style('stroke', 'none')
                          
                          d3.selectAll('#{{ chartId }} svg .node rect')
                          .style('fill', function(d) { return colors[d.name] })
                          .style('stroke', function(d) { d3.rgb(colors[d.name]).darker(2); })
                          </script>", json)
  
  
  
  widget$setTemplate(afterScript = after_script)
  return(widget)
}

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

colors = rep(sample(brewer.pal(12, "Paired"), 11), 6)
sankeyPlot = change_node_colors(sankeyPlot, colors = colors)

# sankeyPlot$setTemplate(
#   afterScript = "
#   <script>
#   var cscale = d3.scale.category20b();
# 
# 
#   d3.selectAll('#{{ chartId }} svg path.link')
#   .style('stroke', function(d){
#   return cscale(d.source.name);
#   })
# 
#   d3.selectAll('#{{ chartId }} svg .node rect')
#   .style('fill', function(d){
#   return cscale(d.name)
#   })
#   .style('stroke', 'none')
#   </script>
#   ")

sankeyPlot
