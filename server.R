library(shiny)
library(shinydashboard)

shinyServer(function(input, output, session){
  
  ### season stat input functions
  
  current_player = reactive({
    req(input$player_name)
    find_player_by_name(input$player_name)
  })
  
  current_player_seasons = reactive({
    req(current_player())
    
    first = max(current_player()$from_year, first_year_of_data)
    if (current_player()$to_year == "2022") {
      last = "2021"
    } else {
      last = current_player()$to_year
    }
    as.character(season_strings[as.character(first:last)])
  })
  
  current_season = reactive({
    req(input$season)
    input$season
  })
  
  update_season_input = observe({
    req(current_player(), current_player_seasons())
    
    isolate({
      if (current_season() %in% current_player_seasons()) {
        selected_value = current_season()
      } else {
        selected_value = rev(current_player_seasons())[1]
      }
      
      updateSelectInput(session,
                        "season",
                        choices = rev(current_player_seasons()),
                        selected = selected_value)
    })
  })
  
  current_season_type = reactive({
    req(input$season_type)
    input$season_type
  })
  
  court_theme = reactive({
    court_themes[[tolower("light")]]
  })
  
  shot_name = reactive({
    req(input$shot_type)
    
    if (input$shot_type == "All Shots") {
      "fg"
    } else if (input$shot_type == "2PT") {
      "fg2"
    } else if (input$shot_type == "3PT") {
      "fg3"
    } else {
      "ft"
    }
  })
  
  ### career functions
  
  career_gamelogs = reactive({
    req(current_player(), current_player_seasons(), current_season_type())
    req(shot_name())
    
    n = c("season", "mean", "median", "mode", "sd", "skew")
    career_stats = data.frame(matrix(ncol=length(n), nrow=0))
    colnames(career_stats) = n
    career_stats = as_tibble(career_stats) %>% mutate(
      season = as.character(season),
      mean = as.numeric(as.character(mean)),
      median = as.numeric(as.character(median)),
      mode = as.numeric(as.character(mode)),
      sd = as.numeric(as.character(sd)),
      skew = as.numeric(as.character(skew))
    )
    
    for (season in current_player_seasons()) {
      print(season)
      season_gamelog = get_player_gamelog(
        current_player()$person_id,
        season,
        current_season_type()
      )
      if (dim(season_gamelog)[1] <= 1) {
        next
      } else {
        dmode = density_mode(season_gamelog, shot_name())
        moment = third_moment(season_gamelog, shot_name())
        
        season_gamelog = mutate(season_gamelog,
          season = season,
          mean = mean(!!as.name(paste0(shot_name(), "_pct"))),
          median = median(!!as.name(paste0(shot_name(), "_pct"))),
          sd = sd(!!as.name(paste0(shot_name(), "_pct"))),
          mode = dmode,
          skew = moment
        )
        
        career_stats = bind_rows(career_stats, season_gamelog)
      }
      Sys.sleep(0.3)
    }
    
    career_stats
  })
  
  var_plot_c = reactive({
    req(career_gamelogs())
    
    ggplot(career_gamelogs(), aes(x=season, y=mean, group=1)) + 
      ylim(0, 1) +
      geom_line(size = 2) +
      geom_point(size = 2) +
      geom_point(aes(x=season, y=mean+(skew/2)), color="orange", size = 2) +
      theme_solarized()
  })
  
  ### shot chart functions
  
  shots = reactive({
    req(current_player(), current_season(), current_season_type())
    req(current_season() %in% current_player_seasons())
    
    use_default_shots = all(
      current_player()$person_id == default_player$person_id,
      current_season() == default_season,
      current_season_type() == default_season_type
    )
    
    if (use_default_shots) {
      default_shots
    } else {
      get_shots_by_player_id_and_season(
        current_player()$person_id,
        current_season(),
        current_season_type()
      )
    }
  })
  
  filtered_shots = reactive({
    req(shots()$player, input$shot_type)
    
    if (input$shot_type == "2PT") {
      filter(shots()$player,
             shot_zone_basic != "Backcourt",
             is.na(input$shot_type) | shot_type == "2PT Field Goal",
             is.na(input$date_range[1]) | game_date >= input$date_range[1],
             is.na(input$date_range[2]) | game_date <= input$date_range[2])
    } else if (input$shot_type == "3PT") {
      filter(shots()$player,
             shot_zone_basic != "Backcourt",
             is.na(input$shot_type) | shot_type == "3PT Field Goal",
             is.na(input$date_range[1]) | game_date >= input$date_range[1],
             is.na(input$date_range[2]) | game_date <= input$date_range[2])
    } else if (input$shot_type == "FT") {
      filter(shots()$player,
             shot_zone_basic != "Backcourt",
             is.na(input$shot_type) | shot_type == "FT Field Goal",
             is.na(input$date_range[1]) | game_date >= input$date_range[1],
             is.na(input$date_range[2]) | game_date <= input$date_range[2])
    } else {
      filter(shots()$player,
             shot_zone_basic != "Backcourt",
             is.na(input$date_range[1]) | game_date >= input$date_range[1],
             is.na(input$date_range[2]) | game_date <= input$date_range[2])
    }
  })
  
  court_plot = reactive({
    req(court_theme())
    plot_court(court_theme = court_theme())
  })
  
  shot_chart = reactive({
    req(
      filtered_shots(),
      current_player(),
      current_season(),
      court_plot()
    )
    
    generate_scatter_chart(
      filtered_shots(),
      base_court = court_plot(),
      court_theme = court_theme(),
      alpha = 0.7,
      size = 4
    )
    
  })
  
  ### gamelog functions
  
  gamelog = reactive({
    req(current_player(), current_season(), current_season_type())
    req(current_season() %in% current_player_seasons())
    req(shot_name())
    
    raw_gamelog = get_player_gamelog(
      current_player()$person_id,
      current_season(),
      current_season_type()
    )
    
    if (!is.na(input$date_range[1]) & !is.na(input$date_range[2])) {
        filter(raw_gamelog,
               !!as.name(paste0(shot_name(), "a")) != 0,
               is.na(input$date_range[1]) | game_date >= input$date_range[1],
               is.na(input$date_range[2]) | game_date <= input$date_range[2])
    } else {
        filter(raw_gamelog,
               !!as.name(paste0(shot_name(), "a")) != 0)
    }
  })
  
  var_plot = reactive({
    req(gamelog(), shot_name())
    
    ggplot(gamelog(), aes(x=!!as.name(paste0(shot_name(), "_pct")))) + 
      geom_histogram(binwidth = 0.04) +
      geom_density(alpha=0.2, size=2) + 
      xlim(0, 1) + ylim(0, 10) + 
      labs(x=paste0("(", input$shot_type, ") ", "Shooting Percentage (%)"),
           y="Density") + 
      geom_vline(aes(xintercept=mean(!!as.name(paste0(shot_name(), "_pct")))), 
                 linetype="dashed", size=2, color="#499fc7", show.legend = TRUE) + 
      geom_vline(aes(xintercept=density_mode(gamelog(), shot_name())), 
                 linetype="dashed", size=2, color="#605ca3") + 
      geom_vline(aes(xintercept=median(!!as.name(paste0(shot_name(), "_pct")))), 
                 linetype="dashed", size=2, color="#4aa362") +
      geom_segment(aes(x=mean(!!as.name(paste0(shot_name(), "_pct"))),
                       y=8,
                       xend=mean(!!as.name(paste0(shot_name(), "_pct"))) + 
                         (third_moment(gamelog(), shot_name())) / 2,
                       yend=8), 
                   arrow=arrow(length=unit(0.03, "npc")),
                   size=2, color="#ef8c3b") +
      theme_solarized()
  })
  
  ### season stat outputs
  
  output$player_photo = renderUI({
    if (input$player_name == "") {
      tags$img(src = "https://i.imgur.com/hXWPTOF.png", alt = "photo")
    } else if (req(current_player()$person_id)) {
      tags$img(src = player_photo_url(current_player()$person_id), alt = "photo")
    }
  })
  
  output$court = renderPlot({
    req(shot_chart())
    withProgress({
      shot_chart()
    }, message = "Calculating...")
  }, bg = "transparent")
  
  output$fg_var = renderPlot({
    req(var_plot())
    withProgress({
      var_plot()
    }, message = "Calculating...")
  }, bg = "transparent")
  
  output$shoot_percent = renderValueBox({
    req(gamelog(), shot_name())
    valueBox(
      paste0(round(shooting_stats(gamelog(), shot_name())$shooting_percent,
                   digits = 1), "%"), 
      paste("Mean", input$shot_type, "Shooting"), 
      icon = icon("basketball")
    )
  })
  
  output$shoot_median = renderValueBox({
    req(gamelog(), shot_name())
    valueBox(
      paste0(round(shooting_stats(gamelog(), shot_name())$shooting_median, 
                   digits = 1), "%"), 
      paste("Median", input$shot_type, "Shooting"), 
      icon = icon("align-center"),
      color = "green"
    )
  })
  
  output$shoot_mode = renderValueBox({
    req(gamelog(), shot_name())
    valueBox(
      paste0(round(density_mode(gamelog(), shot_name()) * 100, 
                   digits = 1), "%"), 
      paste("Mode", input$shot_type, "Shooting"), 
      icon = icon("align-center"),
      color = "purple"
    )
  })
  
  output$shoot_variance = renderValueBox({
    req(gamelog(), shot_name())
    valueBox(
      paste0(round(shooting_stats(gamelog(), shot_name())$shooting_std_dev, 
                   digits = 1), "%"), 
      paste("SD", input$shot_type, "Shooting"), 
      icon = icon("chart-area"),
      color = "yellow"
    )
  })
  
  output$shoot_skewness = renderValueBox({
    req(gamelog(), shot_name())
    valueBox(
      paste0(round(third_moment(gamelog(), shot_name()) * 100, 
                   digits = 1), "%"), 
      paste("Skewness", input$shot_type, "Shooting"), 
      icon = icon("chart-area"),
      color = "orange"
    )
  })
  
  ### career stat outputs
  
  output$player_photo_c = renderUI({
    if (input$player_name == "") {
      tags$img(src = "https://i.imgur.com/hXWPTOF.png", alt = "photo")
    } else if (req(current_player()$person_id)) {
      tags$img(src = player_photo_url(current_player()$person_id), alt = "photo")
    }
  })
  
  output$fg_var_c = renderPlot({
    req(var_plot_c())
    withProgress({
      var_plot_c()
    }, message = "Calculating...")
  }, height = 800, bg = "transparent")
  
})