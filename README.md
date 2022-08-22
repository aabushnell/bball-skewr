# bball-skewr
R Shiny App Showing Skewness in NBA Shooting

Use the following lines of code (with R installed) to run the app locally:

```R
packages = c("shiny", "tidyverse", "httr", "jsonlite", "moments", "ggthemes", "shinydashboard")
install.packages(packages, repos = "https://cran.rstudio.com/")
library(shiny)
runGitHub("bball-skewr", "aabushnell")
```

## Instructions

The app currently consists of two pages accessible through the menu on the left. The first tab allows you to select an NBA player, season, date-range (optional), and shot-type (2PT FGs, 3PT FGs, etc.) and displays a shot chart and a histogram on the left. The histogram shows the distribution of per-game shooting percentages for the chosen shot type, player, and season. It also shows several measures of central tendacy -- i.e. the mean, median, and (density) mode -- the standard deviation, and a measure of skewness calculated from the third standardized moment (https://en.wikipedia.org/wiki/Standardized_moment).

The second tab allows you to look at the selected players per-season shooting percentages for their entire career with the per-season skewness overlayed on the trendline as orange arrows. Note that due to the large volume of data that must be loaded from the NBA API and processed this page may take a few seconds to load.

## Theory

The concept of skewness attempts to capture deviation from a standard normal distribution. Generally when discussing statistics like a sample mean or other more complex measures there is an implicit assumption that the distribution from which the statistic is derived is distributed approximately normal. However, when this assumption is not true, the underlying results can differ from theoretical ones. 

As such there may be cases when simply looking at a sample mean (i.e. a season shooting percentage for an NBA player) can be misleading and not tell the full story of the actual results produced by the player. A positively skewed shooting season could be an indicator that a player's shooting had a more positive impact overall that a simple mean would indicate. 

It could also be an indicator of latent potential, i.e. a player (for whatever reason), underperformed what they otherwise could have shot under different conditions. This potential may have peaked through in certain games producing a skewed and/or bimodal distribution. Understanding why this skewness occured could allow a player or coach to unlock this latent potential.

## Example

For example, during the 2021-22 regular season, Steph Curry shot a notably low (for his standards) ~38% from three. However, he had a +24% skewness to his shooting distrubition with a notable second peak to the right of the 38% mean creating a clear bimodal distribution. Many explanations for the statistically abberant 3-pt shooting have been given, including fatigue, mental pressure, and an altered minutes rotation. 

![Skewr Example](https://github.com/aabushnell/bball-skewr/blob/master/Screenshot_Curry.png)

The large positive skewness would seem to contribute to the idea that some change (like a non-standard rotation pattern) artifically suppressed the overall shooting number. Optimists would take this as a sign that his shooting should bounce back in the following season. However, these statistics are not meant to be an oracle, but rather an opening point for further thought and analysis.

## Future

This app is currently a relatively simple visualization tool for examining different players shot distributions and skewness, however, further work investigating the statistical potential of skewness to predict shooting in later seasons could further shed light on the significance of this concept.
