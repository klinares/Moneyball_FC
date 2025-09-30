#______________________________________________________________________________
#____ Here be the UEFA 1o year coefficient standings for European teams _______
#___ https://www.uefa.com/nationalassociations/uefarankings/club/?year=2025 ___
#______________________________________________________________________________


# Load the tidyverse library
library(arrow)
library(tidyverse)

# path to repo
repo_path <- "D:/repos/Moneyball_FC/"

# --- 1. Recreate the 'all_coeffs' tibble from the website ---
all_coeffs <- tribble(
  ~Pos, ~Club, ~`15/16`, ~`16/17`, ~`17/18`, ~`18/19`, ~`19/20`, ~`20/21`, ~`21/22`,
  ~`22/23`, ~`23/24`, ~`24/25`, ~Total_Pts, ~Assoc_Coeff, ~Country,
  3, "Man City", 26, 18, 22, 25, 10, 35, 27, 33, 28, 14.75, 253.75, 41.131, "England",
  6, "Liverpool", 22, NA, 30, 29, 18, 24, 33, 19, 20, 29.5, 224.5, 41.131, "England",
  8, "Man Utd", 13, 26, 20, 19, 22, 26, 18, 19, 7, 32.5, 202.5, 41.131, "England",
  9, "Chelsea", 18, NA, 18, 30, 17, 33, 25, 21, NA, 30, 192, 41.131, "England",
  12, "Arsenal", 15, 19, 21, 26, 10, 23, NA, 17, 22, 36, 189, 41.131, "England",
  18, "Tottenham", 12, 10, 21, 26, 16, 15, 5, 18, NA, 32.25, 155.25, 41131, "England",
  16, "Benfica", 22, 17, 4, 17, 10, 10, 20, 25, 14, 18.75, 157.75, 22.343, "Portugal",
  19, "Porto", 11, 17, 17, 23, 7, 23, 10, 18, 19, 9.75, 154.75, 22.343, "Portugal",
  1, "Real Madrid", 33, 33, 32, 19, 17, 26, 30, 29, 34, 24.5, 277.5, 39.347, "Spain",
  5, "Barcelona", 26, 23, 25, 30, 24, 20, 15, 9, 23, 36.25, 231.25, 39.347, "Spain",
  7, "Atleti", 28, 29, 28, 20, 22, 16, 19, 8, 24, 26.5, 220.5, 39.347, "Spain",
  15, "Sevilla", 23, 19, 21, 13, 26, 19, 12, 21, 6, NA, 160, 39.347, "Spain",
  21, "Villarreal", 23, 9, 8, 16, NA, 30, 24, 12, 16, NA, 138, 39.347, "Spain",
  2, "Bayern München", 29, 22, 29, 20, 36, 27, 26, 27, 28, 27.25, 271.25, 32.223, "Germany",
  10, "B. Dortmund", 17, 22, 10, 18, 18, 22, 10, 18, 29, 27.75, 191.75, 32.223, "Germany",
  17, "Leverkusen", 14, 18, NA, 11, 18, 10, 14, 19, 29, 23.25, 156.25, 32.223, "Germany",
  4, "Paris", 24, 20, 19, 19, 31, 24, 19, 19, 23, 33.5, 231.5, 26.468, "France",
  11, "Juventus", 18, 33, 23, 21, 22, 21, 20, 17, NA, 16.25, 191.25, 33.576, "Italy",
  13, "Roma", 14, 13, 25, 17, 11, 24, 23, 22, 21, 14.5, 184.5, 33.576, "Italy",
  14, "Inter", NA, 4, NA, 15, 25, 9, 18, 29, 20, 40.25, 160.25, 33.576, "Italy",
  20, "Napoli", 13, 17, 10, 18, 19, 10, 9, 25, 17, NA, 138, 33.576, "Italy",
)

# --- 2. Recreate the 'team_urls_df' tibble ---
team_urls_df <- tribble(
  ~Country, ~Club, ~team_url,
  "England", "Man City", "https://www.transfermarkt.com/manchester-city/startseite/verein/281/saison_id/2024",
  "England", "Liverpool", "https://www.transfermarkt.com/fc-liverpool/startseite/verein/31/saison_id/2024",
  "England", "Man Utd", "https://www.transfermarkt.com/manchester-united/startseite/verein/985/saison_id/2024",
  "England", "Chelsea", "https://www.transfermarkt.com/fc-chelsea/startseite/verein/631/saison_id/2024",
  "England", "Arsenal", "https://www.transfermarkt.com/fc-arsenal/startseite/verein/11/saison_id/2024",
  "England", "Tottenham", "https://www.transfermarkt.com/fc-tottenham/startseite/verein/148/saison_id/2024",
  "Portugal", "Benfica", "https://www.transfermarkt.com/benfica-lissabon/startseite/verein/294/saison_id/2024",
  "Portugal", "Porto", "https://www.transfermarkt.com/fc-porto/startseite/verein/720/saison_id/2024",
  "Spain", "Real Madrid", "https://www.transfermarkt.com/real-madrid/startseite/verein/418/saison_id/2024",
  "Spain", "Barcelona", "https://www.transfermarkt.com/fc-barcelona/startseite/verein/131/saison_id/2024",
  "Spain", "Atleti", "https://www.transfermarkt.com/atletico-madrid/startseite/verein/13/saison_id/2024",
  "Spain", "Sevilla", "https://www.transfermarkt.com/fc-sevilla/startseite/verein/368/saison_id/2024",
  "Spain", "Villarreal", "https://www.transfermarkt.com/fc-villarreal/startseite/verein/1049/saison_id/2024",
  "Germany", "Bayern München", "https://www.transfermarkt.com/fc-bayern-munchen/startseite/verein/27/saison_id/2024",
  "Germany", "B. Dortmund", "https://www.transfermarkt.com/borussia-dortmund/startseite/verein/16/saison_id/2024",
  "Germany", "Leverkusen", "https://www.transfermarkt.com/bayer-04-leverkusen/startseite/verein/15/saison_id/2024",
  "France", "Paris", "https://www.transfermarkt.com/paris-saint-germain/startseite/verein/583/saison_id/2024",
  "Italy", "Juventus", "https://www.transfermarkt.com/juventus-turin/startseite/verein/506/saison_id/2024",
  "Italy", "Roma", "https://www.transfermarkt.com/as-rom/startseite/verein/12/saison_id/2024",
  "Italy", "Inter", "https://www.transfermarkt.com/inter-mailand/startseite/verein/46/saison_id/2024",
  "Italy", "Napoli", "https://www.transfermarkt.com/ssc-neapel/startseite/verein/6195/saison_id/2024"
  )


# --- 3. Combine the two tables ---
all_coeffs_with_urls <- left_join(all_coeffs, 
                                  team_urls_df, by = c("Club", "Country")) |> 
  select(Pos, Club, Country, Total_Pts, team_url)

# --- 4. Print the final, combined table ---
write_parquet(all_coeffs_with_urls, str_c(
  repo_path, "inputs/uefa_standing.parquet")
)


