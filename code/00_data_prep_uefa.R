# Data Preparation: Integrate UEFA Rankings
# Author: Moneyballers
# Date: November 7, 2025

library(arrow)
library(tidyverse)

# Set repo path
repo_path <- "/Users/namomac/Desktop/Moneyball_FC/"

cat("=== STEP 1: Reading UEFA Standings Data ===\n")
# Read the UEFA standings data
uefa_standings <- read_parquet(paste0(repo_path, "inputs/uefa_standing.parquet"))

# Inspect the structure
cat("\nUEFA Data Structure:\n")
glimpse(uefa_standings)

cat("\n=== STEP 2: Preparing UEFA Variables ===\n")
# Create clean UEFA data for merging
club_uefa <- uefa_standings %>%
  select(
    Club,
    Country,
    uefa_rank = Pos,           # Rename for clarity
    uefa_coefficient = Total_Pts  # Rename for clarity
  ) %>%
  mutate(
    # Center UEFA coefficient for interpretation
    uefa_coef_cen = uefa_coefficient - mean(uefa_coefficient, na.rm = TRUE),
    
    # Create categorical tiers based on ranking
    uefa_tier = case_when(
      uefa_rank <= 5 ~ "Elite (Top 5)",
      uefa_rank <= 10 ~ "Top 10",
      uefa_rank <= 15 ~ "Top 15",
      TRUE ~ "Top 21"
    ),
    uefa_tier = factor(uefa_tier, levels = c("Elite (Top 5)", "Top 10", 
                                               "Top 15", "Top 21"))
  )

# Display the prepared data
cat("\nUEFA Data Summary:\n")
print(club_uefa %>% arrange(uefa_rank))

cat("\n=== STEP 3: Reading Player Data ===\n")
# Read player data
player_df <- read_parquet(paste0(repo_path, "inputs/player_df.parquet"))

cat("Original player data dimensions:", nrow(player_df), "rows,", ncol(player_df), "columns\n")

cat("\n=== STEP 4: Merging UEFA Data with Player Data ===\n")
# Prepare clean data with UEFA rankings
clean_player_df_uefa <- player_df %>%
  mutate(
    player_id = factor(player_id),
    club_id = factor(club_id),
    position = factor(position),
    Region = factor(Region),
    citizen_of_club_country = factor(citizen_of_club_country)
  ) %>%
  na.omit() %>%
  mutate(
    mean_age = mean(Age),
    mean_height = mean(height_in_cm),
    age_cen = Age - mean_age,
    height_cen = height_in_cm - mean_height
  ) %>%
  # Join with UEFA data
  left_join(club_uefa, by = "Club")

cat("After cleaning and merging:", nrow(clean_player_df_uefa), "rows,", 
    ncol(clean_player_df_uefa), "columns\n")

cat("\n=== STEP 5: Verifying Merge Quality ===\n")
# Check the merge
merge_check <- clean_player_df_uefa %>%
  group_by(Club, uefa_rank, uefa_coefficient) %>%
  summarise(n_observations = n(), .groups = "drop") %>%
  arrange(uefa_rank)

cat("\nObservations per Club (ordered by UEFA rank):\n")
print(merge_check, n = 21)

# Verify no missing UEFA data
cat("\n=== STEP 6: Checking for Missing UEFA Data ===\n")
missing_check <- clean_player_df_uefa %>%
  summarise(
    missing_rank = sum(is.na(uefa_rank)),
    missing_coef = sum(is.na(uefa_coefficient)),
    missing_tier = sum(is.na(uefa_tier))
  )

print(missing_check)

if(missing_check$missing_rank > 0) {
  cat("\n⚠ WARNING: Missing UEFA data detected!\n")
  cat("Clubs with missing UEFA data:\n")
  print(unique(clean_player_df_uefa$Club[is.na(clean_player_df_uefa$uefa_rank)]))
} else {
  cat("\n✓ No missing UEFA data - merge successful!\n")
}

cat("\n=== STEP 7: UEFA Statistics Summary ===\n")
cat("\nUEFA Coefficient Statistics:\n")
cat("  Mean:", round(mean(club_uefa$uefa_coefficient), 2), "\n")
cat("  SD:", round(sd(club_uefa$uefa_coefficient), 2), "\n")
cat("  Range:", range(club_uefa$uefa_coefficient), "\n")

cat("\nUEFA Tier Distribution:\n")
print(table(club_uefa$uefa_tier))

cat("\n=== STEP 8: Saving Enhanced Dataset ===\n")
# Save the enhanced dataset
write_parquet(clean_player_df_uefa, 
              paste0(repo_path, "inputs/player_df_with_uefa.parquet"))

cat("\n✓✓✓ UEFA data successfully integrated and saved! ✓✓✓\n")
cat("\nSaved to:", paste0(repo_path, "inputs/player_df_with_uefa.parquet"), "\n")
cat("\nYou can now use this dataset for modeling.\n")
