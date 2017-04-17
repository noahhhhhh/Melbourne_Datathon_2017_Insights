require(chorddiag)

# transform ---------------------------------------------------------------

ilness = unique(dt_txn_ilness$ChronicIllness)
ilness = ilness[!is.na(ilness)]

df2Zero = function(x){
  
  df = as.data.frame(matrix(rep(0, length(x)^2), length(x), length(x)))
  colnames(df) = x
  rownames(df) = x
  
  return(df)
  
}

distMatrix = function(x, df){
  x = gsub(", ", "|", x)
  
  for(i in 1:nrow(df)){
    for(j in 1:ncol(df)){
      # print(paste("i:", i, "j:", j))
      if(i != j){
        if(all(grepl(x, ilness[i]), grepl(x, ilness[j]))){
          df[i, j] = df[i, j] + 1
        }
      }
    }
  }
  
  return(df)
  
}

df = df2Zero(ilness)

# dt_basket_ilnesss_pairs_sample = dt_basket_ilnesss_pairs[sample(1:nrow(dt_basket_ilnesss_pairs), 10)]

for(i in 1:nrow(dt_basket_patient_ilnesss_pairs)){
  x = dt_basket_patient_ilnesss_pairs[i]$ChronicIllness
  df = df + distMatrix(x, df2Zero(ilness))
}

df = df[c(1, 3:11), c(1, 3:11)] # remove 0

m = as.matrix(df)

groupColors = RColorBrewer::brewer.pal(nrow(df), "Paired") 
chorddiag(m, groupColors = groupColors, groupnamePadding = 20, groupnameFontsize = 14, showTicks = F)
