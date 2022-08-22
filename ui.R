library(shiny)
library(tidyverse)
library(httr)
library(jsonlite)
library(moments)
library(ggthemes)
library(shinydashboard)

source("helpers.R")
source("court_themes.R")
source("plot_court.R")
source("players_data.R")
source("get_shots.R")
source("scatter_chart.R")
source("player_gamelog.R")
source("calculate_stats.R")

shinyUI(
  dashboardPage(skin = "yellow",
    dashboardHeader(title = "Shooting Variance"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Season", tabName = "season", icon = icon("dashboard")),
        menuItem("Career", tabName = "career", icon = icon("th"))
      )
    ),
    dashboardBody(
      tags$head(
        tags$link(rel = "apple-touch-icon", href = "basketball.png"),
        tags$link(rel = "icon", href = "basketball.png"),
        tags$link(rel = "stylesheet", type = "text/css", href = "shared/selectize/css/selectize.bootstrap3.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.10.0/css/bootstrap-select.min.css"),
        # tags$link(rel = "stylesheet", type = "text/css", href = "custom_styles.css"),
        tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/html2canvas/0.4.1/html2canvas.min.js"),
        tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.10.0/js/bootstrap-select.min.js"),
        tags$script(src = "shared/selectize/js/selectize.min.js"),
        tags$script(src = "skewr.js")
      ),
      tabItems(
        # First tab content
        tabItem(tabName = "season",
                fluidRow(
                  column(width = 7,
                    box(plotOutput("fg_var"), width = NULL),
                    box(plotOutput("court"), width = NULL)
                  ),
                  column(width = 2,
                    valueBoxOutput("shoot_percent", width = NULL),
                    valueBoxOutput("shoot_median", width = NULL),
                    valueBoxOutput("shoot_mode", width = NULL),
                    valueBoxOutput("shoot_variance", width = NULL),
                    valueBoxOutput("shoot_skewness", width = NULL)
                  ),
                  column(width = 3,
                    box(width = NULL,
                        uiOutput("player_photo"),
                        
                        selectInput(inputId = "player_name",
                                    label = "Player",
                                    choices = c("Enter a player..." = "", available_players$name),
                                    selected = default_player$name,
                                    selectize = FALSE),
                        
                        selectInput(inputId = "season",
                                    label = "Season",
                                    choices = rev(default_seasons),
                                    selected = default_season,
                                    selectize = FALSE),
                        
                        radioButtons(inputId = "season_type",
                                     label = "Season Type",
                                     choices = c("Regular Season", "Playoffs"),
                                     selected = default_season_type),
                        
                        dateRangeInput(inputId = "date_range",
                                       label = "Date range",
                                       start = FALSE,
                                       end = FALSE),
                        
                        radioButtons(inputId = "shot_type",
                                     label = "Shot Type",
                                     choices = c("All Shots", "2PT", "3PT", "FT"),
                                     selected = "All Shots")
                        
                    )
                  )
                )
        ),
        
        # Second tab content
        tabItem(tabName = "career",
            fluidRow(
                column(width = 9, height = 900,
                      box(plotOutput("fg_var_c"), width = NULL, height = 900)
                ),
                column(width = 3,
                       box(width = NULL,
                           uiOutput("player_photo_c")
                           
                       )
                )
            )
        )
      )
    )
  )
)