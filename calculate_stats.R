density_mode = function(df, shot) {
  col_name = paste0(shot, "_pct")
  v = na.omit(df[[col_name]])
  max_x = which.max(density(v)$y)
  
  return(density(v)$x[max_x])
}

third_moment = function(df, shot) {
  col_name = paste0(shot, "_pct")
  
  return(skewness(df[[col_name]]))
}

shooting_stats = function(df, shot) {
  sum_stats = df %>%
    summarise(
      shooting_percent = sum(!!as.name(paste0(shot, "m"))) 
      / sum(!!as.name(paste0(shot, "a"))) * 100,
      shooting_mean = mean(!!as.name(paste0(shot, "_pct"))) * 100,
      shooting_median = median(!!as.name(paste0(shot, "_pct"))) * 100,
      shooting_std_dev = sd(!!as.name(paste0(shot, "_pct"))) * 100
    )
  
  return(sum_stats)
}
