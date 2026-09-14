# ============================================================
# ANALIZA DE CORESPONDENȚĂ:
# VÂRSTĂ × UTILIZAREA TIKTOK/INSTAGRAM
# ============================================================

library(readxl)
library(dplyr)
library(FactoMineR)
library(factoextra)

# 1. Importarea datelor
date <- read_excel("anonymous-survey-responses.xlsx")

# 2. Selectarea variabilelor
varsta <- date$`Care este vârsta dumneavoastră?`

tiktok <- date$`Care este sursa/sunt sursele dumneavoastră principală de informare? [TikTok/Instagram]`

# 3. Recodificarea utilizării TikTok/Instagram
utilizare_tiktok <- case_when(
  tiktok %in% c("Niciodată", "Rar") ~ "Utilizare redusă",
  tiktok == "Uneori" ~ "Utilizare moderată",
  tiktok %in% c("Des", "Foarte des") ~ "Utilizare frecventă",
  TRUE ~ as.character(tiktok)
)

# 4. Transformarea în factori
varsta <- as.factor(varsta)
utilizare_tiktok <- as.factor(utilizare_tiktok)

# 5. Tabel de contingență
tabel_varsta_tiktok <- table(varsta, utilizare_tiktok)

tabel_varsta_tiktok
addmargins(tabel_varsta_tiktok)

# 6. Test Chi-pătrat
test_chi <- chisq.test(tabel_varsta_tiktok)

test_chi
test_chi$expected

# 7. Analiza de corespondență
AC_varsta_tiktok <- CA(tabel_varsta_tiktok, graph = FALSE)

summary(AC_varsta_tiktok)

# 8. Grafic final
fviz_ca_biplot(
  AC_varsta_tiktok,
  repel = TRUE,
  col.row = "blue",
  col.col = "red",
  title = "Asocierea dintre vârstă și utilizarea TikTok/Instagram"
)
