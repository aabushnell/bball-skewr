required_ggplot2_version = "3.0.0"

if (packageVersion("ggplot2") < required_ggplot2_version) {
  stop(paste(
    "ggplot2 version",
    packageVersion("ggplot2"),
    "detected; please upgrade to at least",
    required_ggplot2_version
  ))
}

fun.mode = function(x){
  as.numeric(names(sort(-table(x)))[1])
}

mode = function(codes){
  which.max(tabulate(codes))
}

fraction_to_percent_format = function(frac, digits = 1) {
  paste0(format(round(frac * 100, digits), nsmall = digits), "%")
}

percent_formatter = function(x) {
  scales::percent(x, accuracy = 1)
}

points_formatter = function(x) {
  scales::comma(x, accuracy = 0.01)
}
