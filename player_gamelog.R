get_player_gamelog = function(player_id, season, season_type) {
  request_headers = c(
    "Accept" = "application/json, text/plain, */*",
    "Accept-Language" = "en-US,en;q=0.8",
    "Cache-Control" = "no-cache",
    "Connection" = "keep-alive",
    "Host" = "stats.nba.com",
    "Pragma" = "no-cache",
    "Referer" = "https://www.nba.com/",
    "Upgrade-Insecure-Requests" = "1",
    "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
  )
  
  request = GET(
    "https://stats.nba.com/stats/playergamelog",
    query = list(
      PlayerID = player_id,
      Season = season,
      SeasonType = season_type
    ),
    add_headers(request_headers)
  )
  
  stop_for_status(request)
  
  gamelog_data = content(request)
  
  raw_gamelog_data = gamelog_data$resultSets[[1]]$rowSet
  gamelog_col_names = tolower(as.character(gamelog_data$resultSets[[1]]$headers))
  
  if (length(raw_gamelog_data) == 0) {
    gamelog = data.frame(
      matrix(nrow = 0, ncol = length(gamelog_col_names))
    )
  } else {
    gamelog = data.frame(
      matrix(
        unlist(raw_gamelog_data),
        ncol = length(gamelog_col_names),
        byrow = TRUE
      )
    )
  }
  
  gamelog = as_tibble(gamelog)
  names(gamelog) = gamelog_col_names
  
  gamelog = gamelog %>%
    select(game_date, matchup, wl, min, fgm, fga, fg_pct, fg3m, fg3a, fg3_pct,
           ftm, fta, ft_pct, pts) %>%
    mutate(
    game_date = as.Date(game_date, format="%b %d,%Y"),
    matchup = as.character(matchup),
    wl = as.character(wl),
    min = as.numeric(as.character(min)),
    fgm = as.numeric(as.character(fgm)),
    fga = as.numeric(as.character(fga)),
    fg_pct = as.numeric(as.character(fg_pct)),
    fg3m = as.numeric(as.character(fg3m)),
    fg3a = as.numeric(as.character(fg3a)),
    fg3_pct = as.numeric(as.character(fg3_pct)),
    fg2m = fgm - fg3m,
    fg2a = fga - fg3a,
    fg2_pct = fg2m / fg2a,
    ftm = as.numeric(as.character(ftm)),
    fta = as.numeric(as.character(fta)),
    ft_pct = as.numeric(as.character(ft_pct)),
    pts = as.numeric(as.character(pts))
    )
  
  return(gamelog)
}
