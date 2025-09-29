

library(worldfootballR)
library(future)
library(furrr)
library(progressr)
library(tidyverse)

options(scipen=999)


data_path <- "D:/soccer/inputs/"

# read in club rankings, use to filer teams
team_urls_df <- read_csv(str_c(
  data_path, "uefa_standing.csv") )



# read in player data 
player_valuations <-  read_csv(str_c(data_path, "player_valuations.csv") ) |> 
  mutate(season_year = lubridate::year(date)) |> 
  group_by(player_id, current_club_id, season_year) |> 
  # take yearly average for market value
  reframe(market_value_ave = mean(market_value_in_eur)) |> 
  rename(club_id = current_club_id) |> 
  # keep players we want for the study
  filter(club_id %in% team_urls_df$club_id)

# read in player season info to get player characteristics
players_season_df <- read_csv(str_c(data_path, "players.csv") ) |> 
  rename(club_id = current_club_id, 
         season_year = last_season) |> 
  # filter teems for this study
  # keep players we want for the study
  filter(club_id %in% team_urls_df$club_id) |> 
  distinct(player_id, name, club_id, country_of_birth, 
         country_of_citizenship, date_of_birth, sub_position, position, 
         height_in_cm)
  
# read in appearance data for game metrics by year
players_appearance <-  read_csv(str_c(data_path, "appearances.csv") ) |> 
  mutate(season_year = lubridate::year(date)) |> 
  group_by(player_id, season_year) |> 
  reframe(yellow_cards = sum(yellow_cards),
          red_cards = sum(red_cards),
          goals = sum(goals),
          assists = sum(assists),
          minutes_played = sum(minutes_played))

# combine player data
players_df <- player_valuations |> 
  left_join(players_season_df, 
            relationship =
              "many-to-many") |> 
  left_join(players_appearance) |> 
  filter(season_year > 2011) |> 
  # convert DOB to age
  mutate(Age =  season_year - lubridate::year(date_of_birth))
  


# --- 1. Generate URLs for each year from 2014 to 2024 ---
seasonal_urls_df <- crossing(team = team_urls_df$Club, season_year = 2012:2024) |> 
  left_join(team_urls_df, by = c("team" = "Club")) |> 
  mutate(
    seasonal_url = str_replace(team_url, "\\d{4}$", as.character(season_year))
  ) 


# we can now build the total yearly market values for each team

# read in club data
team_df <- seasonal_urls_df |> 
  left_join(
    read_csv(str_c(data_path, "clubs.csv") ) 
  ) |> 
  # add average yearly market value
  left_join(
    players_df |> 
      group_by(club_id, season_year) |> 
      reframe(ave_yearly_market_value = mean(market_value_ave ) )
  )

# how many data points per year that went into calculating team-yearly values
players_df |>  
  # add club names
  left_join(team_df |> distinct(team, club_id) |> 
              select(team, club_id), 
            relationship =
              "many-to-many") |> 
  group_by(team, season_year) |> 
  count() |> 
  ungroup() |> 
  ggplot(aes(x=season_year, y=n)) +
  geom_col() +
  facet_wrap(~team)


s
# generate a plot
team_df |> 
  ggplot(aes(x=season_year, y=ave_yearly_market_value)) +
  geom_line() +
  facet_wrap(~team) +
  ggthemes::theme_hc()



# create club-year level predictors aggregated
players_df_aggregated <- players_df |> 
  left_join(
    team_df |> 
      select(team, season_year, Country, club_id),
    relationship = "many-to-many"
  ) |> 
  group_by(club_id, season_year) |> 
  # these are all averages 
  reframe(yellow_cards_g = mean(yellow_cards, na.rm = TRUE),
          red_cards_g = mean(red_cards, na.rm = TRUE),
          goals_g = mean(goals, na.rm = TRUE),
          assists_g = mean(assists, na.rm = TRUE),
          minutes_played_g = mean(minutes_played, na.rm=TRUE),
          foreing_players_g = mean(ifelse(country_of_birth != Country, 
                                             1, 0 ), na.rm=TRUE),
          Age_g = mean(Age, na.rm=TRUE)
  ) D


# combine data together
year_teams_players_df <- players_df |> 
  left_join(
    team_df |> 
      select(team, season_year, Country, club_id, 
             stadium_seats, ave_yearly_market_value),
    relationship = "many-to-many"
  ) |> 
  left_join(players_df_aggregated, relationship = "many-to-many")





