#__________________________________________________________________________
#________________ Source file for data and models _________________________
#____________________ Updated 12/1/25 5pm _________________________________



#_________________________ Helpful Functions ___________________________

# LRT test for 2 random slopes
calculate_lrt_mixture <- function(reduced_model, full_model) {
  
  # 1. Extract Log-Likelihoods
  ll_reduced = as.numeric(logLik(reduced_model))
  ll_full = as.numeric(logLik(full_model))
  
  # 2. Calculate LRT Statistic
  lrt_stat = -2 * (ll_reduced - ll_full)
  
  # 3. Calculate Difference in Parameters (df)
  df_reduced = attr(logLik(reduced_model), "df")
  df_full = attr(logLik(full_model), "df")
  df_diff = df_full - df_reduced
  
  # 4. Calculate P-Value based on the difference
  
  if (df_diff == 3) {
    # --- NEW BLOCK FOR QUADRATIC SLOPE ---
    # Going from 2 Random Effects (Int+Lin) -> 3 Random Effects (Int+Lin+Quad)
    # We add 1 variance + 2 covariances = 3 parameters.
    # The mixture is 0.5 * ChiSq(2) + 0.5 * ChiSq(3)
    p_val = 0.5 * pchisq(lrt_stat, df = 2, lower.tail = FALSE) + 
      0.5 * pchisq(lrt_stat, df = 3, lower.tail = FALSE)
    
    msg = "Mixture of ChiSq(2) and ChiSq(3)"
    
  } else if (df_diff == 2) {
    # Going from 1 Random Effect (Int) -> 2 Random Effects (Int+Lin)
    # Adds 1 variance + 1 covariance = 2 parameters
    p_val = 0.5 * pchisq(lrt_stat, df = 1, lower.tail = FALSE) + 
      0.5 * pchisq(lrt_stat, df = 2, lower.tail = FALSE)
    
    msg = "Mixture of ChiSq(1) and ChiSq(2)"
    
  } else if (df_diff == 1) {
    # Adding a single parameter (e.g. just a variance, no covariance)
    p_val = 0.5 * pchisq(lrt_stat, df = 0, lower.tail = FALSE) + 
      0.5 * pchisq(lrt_stat, df = 1, lower.tail = FALSE)
    
    msg = "Mixture of ChiSq(0) and ChiSq(1)"
    
  } else {
    # Fallback for standard fixed effects comparisons
    p_val = pchisq(lrt_stat, df = df_diff, lower.tail = FALSE)
    msg = paste0("Standard ChiSq(", df_diff, ")")
  }
  
  # Output
  cat("LRT Statistic:", round(lrt_stat, 4), "\n")
  cat("Parameter Diff:", df_diff, "\n")
  cat("Distribution:  ", msg, "\n")
  cat("P-Value:       ", format.pval(p_val, eps = .0001), "\n")
}

#_________________________________ END __________________________________



#____________________ input data and normalize __________________________

clean_player_df <- dat |> 
  mutate(
    player_id = factor(player_id),
    club_id   = factor(club_id),
    # reference groups
    position = fct_relevel(position, "Attack"),
    Region = fct_relevel(Region,  "Europe & Central Asia"),
    # outcome on log scale
    usd_revenue_2024_log = log(usd_revenue_2024),
    # season year
    # scale years with center 2020 for pandomic shock
    season_year_c = as.numeric(scale(season_year, center = 2020)),
    # grand mean centering
    foreign_players = foreign_players - mean(foreign_players, na.rm=TRUE),
    age_c = Age - mean(Age, na.rm=TRUE),
    height_c = height_in_cm - mean(height_in_cm, na.rm=TRUE)
  ) |> 
  # year mean centering
  group_by(season_year_c) |> 
  mutate(uefa_coefficient = 
           uefa_coefficient - mean(uefa_coefficient, na.rm=TRUE), 
         minutes_played = as.numeric(scale(minutes_played))) |> 
  # position centering
  group_by(position) |> 
  mutate(goals = goals - mean(goals, na.rm=TRUE),
         assists = assists - mean(assists, na.rm=TRUE)) |> 
  ungroup() |> 
  drop_na() |> 
  select(season_year:minutes_played, name, position, Age, Club, 
         foreign_players, uefa_coefficient, Region:height_c)

#_________________________________ END __________________________________



#__________________________ Estimate Models _____________________________


# Using bobyqa to handle the complex random effects 
## structure and avoid gradient warnings
strict_control <- lmerControl(optimizer = "bobyqa",
                              optCtrl = list(maxfun = 200000))

model_null <-  lmer(
  usd_revenue_2024_log ~ 
    # random effects
    (1|player_id) + (1|club_id), 
  data = clean_player_df, REML = TRUE,   control = strict_control)



model_time_linear <-  lmer(
  usd_revenue_2024_log ~ 
    # first level fixed effect
    season_year_c +
    # random effects
    (1|player_id) + (1|club_id), 
  data = clean_player_df, REML = TRUE,   control = strict_control)



model_time_cubic <-  lmer(
  usd_revenue_2024_log ~ 
    # first level fixed effect
    # Use poly() with raw=TRUE 
    poly(season_year_c, 3, raw = TRUE) + 
    # random effects
    (1|player_id) + (1|club_id), 
  data = clean_player_df, REML = TRUE,   control = strict_control)



model_slope_quadratic <-  lmer(
  usd_revenue_2024_log ~ 
    # first level fixed effect
    # Use poly() with raw=TRUE 
    poly(season_year_c, 3, raw = TRUE) +  
    # random effects
    (1 | player_id) + (poly(season_year_c, 2, raw = TRUE) | club_id), 
  data = clean_player_df, REML = TRUE,   control = strict_control)



model_player <-  lmer(
  usd_revenue_2024_log ~ 
    # first level fixed effect
    # Use poly() with raw=TRUE 
    poly(season_year_c, 3, raw = TRUE) + 
    # player fixed effects
    height_c + position + citizen_of_club_country + Region +
    poly(age_c, 2, raw = TRUE) +
    goals + assists + red_cards + yellow_cards + minutes_played +
    # club fixed effects
    uefa_coefficient + foreign_players +
    # random effects
    (1 | player_id) + (poly(season_year_c, 2, raw = TRUE) | club_id), 
  data = clean_player_df, REML = TRUE,   control = strict_control)


#__________________________________ END  _______________________________





