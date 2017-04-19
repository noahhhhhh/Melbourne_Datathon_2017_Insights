require(ggplot2)


# yearly distribution -----------------------------------------------------


dt_illness_year = dt_patient_illness_year[, .N, by = c("Year", "ChronicIllness")]

theme_black = function(base_size = 12, base_family = "") {
  
  theme_grey(base_size = base_size, base_family = base_family) %+replace%
    
    theme(
      # Specify axis options
      axis.line = element_blank(),  
      axis.text.x = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.text.y = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.ticks = element_line(color = "white", size  =  0.1),  
      axis.title.x = element_text(size = base_size, color = "white", margin = margin(0, 10, 0, 0)),  
      axis.title.y = element_text(size = base_size, color = "white", angle = 90, margin = margin(0, 10, 0, 0)),  
      axis.ticks.length = unit(0.3, "lines"),   
      # Specify legend options
      legend.background = element_rect(color = NA, fill = "black"),  
      legend.key = element_rect(color = "white",  fill = "black"),  
      legend.key.size = unit(1.2, "lines"),  
      legend.key.height = NULL,  
      legend.key.width = NULL,      
      legend.text = element_text(size = base_size*0.8, color = "white"),  
      legend.title = element_text(size = base_size*0.8, face = "bold", hjust = 0, color = "white"),  
      legend.position = "right",  
      legend.text.align = NULL,  
      legend.title.align = NULL,  
      legend.direction = "vertical",  
      legend.box = NULL, 
      # Specify panel options
      panel.background = element_rect(fill = "black", color  =  NA),  
      panel.border = element_rect(fill = NA, color = "white"),  
      panel.grid.major = element_line(color = "grey35"),  
      panel.grid.minor = element_line(color = "grey20"),  
      panel.spacing = unit(0.5, "lines"),   
      # Specify facetting options
      strip.background = element_rect(fill = "grey30", color = "grey10"),  
      strip.text.x = element_text(size = base_size*0.8, color = "white"),  
      strip.text.y = element_text(size = base_size*0.8, color = "white",angle = -90),  
      # Specify plot options
      plot.background = element_rect(color = "black", fill = "black"),  
      plot.title = element_text(size = base_size*1.2, color = "white"),  
      plot.margin = unit(rep(1, 4), "lines")
      
    )
  
}


ggplot(dt_illness_year, aes(x = Year, y = N,fill = ChronicIllness)) + 
  geom_bar(position = "fill",stat = "identity") + 
  scale_y_continuous(labels = percent_format()) +
  scale_x_continuous(breaks = round(seq(min(dt_illness_year$Year), max(dt_illness_year$Year), by = 1), 1)) +
  xlab("") +
  ylab("") +
  ggtitle("2009 - 2015 Illness Distribution") +
  scale_fill_brewer(palette = "Paired") +
  theme_black()


# sankey ------------------------------------------------------------------

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



