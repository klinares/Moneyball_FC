# Moneyball_FC ⚽📊💰

[Image of a soccer ball made of money]

## Unpacking Player Market Value: A Multilevel Approach

This repository houses the code and data analysis for **Moneyball_FC**, a research project investigating the complex factors driving professional soccer player market values. Moving beyond traditional single-level models, this project employs **Multilevel Regression** to properly account for the hierarchical structure of football data: players nested within clubs, nested within leagues.

### Research Questions Addressed:

* **Variance Decomposition:** How much variation in player market values is explained by individual player attributes versus club and league contexts?
* **Performance-Value Relationship:** Do objective performance metrics (e.g., goals, assists) and subjective factors (e.g., nationality, age, prestige) differentially predict market values across positions and levels?
* **Cross-Level Interactions:** How do club characteristics (e.g., financial strength) moderate the relationship between individual player attributes (e.g., age) and market value?

### Project Features:

* **Data Collection:** Scripts for processing comprehensive player, club, and league data from Transfermarkt.
* **Multilevel Modeling:** R code implementing 3-level hierarchical linear models using `lme4` to robustly estimate fixed and random effects.
* **Variance Component Analysis:** Decomposition of market value variance into player, club, and league levels.
* **Visualization:** `ggplot2` code for generating plots to illustrate key relationships and model outputs.

### Getting Started:

1.  **Clone the Repository:**
    ```bash
    git clone [git@github.com:klinares/Moneyball_FC.git)
    ```
2.  **Install Dependencies:** All necessary R packages are listed at the top of the main script.
3.  **Run the Analysis:** Execute the R scripts in numerical order, starting with data preparation and followed by model fitting.

---

