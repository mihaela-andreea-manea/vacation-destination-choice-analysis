# ============================================================
# ANALIZA DE CORESPONDENȚĂ:
# TIP VACANȚĂ × UTILIZAREA TIKTOK/INSTAGRAM
# ============================================================

library(readxl)
library(dplyr)
library(stringr)
library(FactoMineR)
library(factoextra)

# 1. Importarea datelor
date <- read_excel("anonymous-survey-responses.xlsx")

# 2. Selectarea variabilelor
tip_vacanta <- as.character(date$`Care este tipul dumneavoastră de vacanță preferat?`)

tiktok <- as.character(
  date$`Care este sursa/sunt sursele dumneavoastră principală de informare? [TikTok/Instagram]`
)

# 3. Recodificarea tipului de vacanță
tip_vacanta <- case_when(
  str_detect(str_to_lower(tip_vacanta), "city|break|oraș|oras|urban") ~ "City-break",
  str_detect(str_to_lower(tip_vacanta), "cultur|istor|muze|atrac") ~ "Culturală",
  str_detect(str_to_lower(tip_vacanta), "munte|natur|aventur|drume") ~ "Natură",
  str_detect(str_to_lower(tip_vacanta), "mare|plaj|relax|resort") ~ "Relaxare",
  str_detect(str_to_lower(tip_vacanta), "social|nightlife|club|bar|festival") ~ "Social",
  TRUE ~ as.character(tip_vacanta)
)

# 4. Recodificarea utilizării TikTok/Instagram
utilizare_tiktok <- case_when(
  tiktok %in% c("Niciodată", "Rar") ~ "Utilizare redusă",
  tiktok == "Uneori" ~ "Utilizare moderată",
  tiktok %in% c("Des", "Foarte des") ~ "Utilizare frecventă",
  TRUE ~ NA_character_
)

# 5. Transformarea în factori
tip_vacanta <- factor(
  tip_vacanta,
  levels = c("City-break", "Culturală", "Natură", "Relaxare", "Social")
)

utilizare_tiktok <- factor(
  utilizare_tiktok,
  levels = c("Utilizare redusă", "Utilizare moderată", "Utilizare frecventă")
)

# 6. Baza finală pentru analiză
date_finale <- na.omit(data.frame(tip_vacanta, utilizare_tiktok))

# 7. Tabel de contingență
tabel_tip_tiktok <- table(
  date_finale$tip_vacanta,
  date_finale$utilizare_tiktok
)

tabel_tip_tiktok
addmargins(tabel_tip_tiktok)

# 8. Test Chi-pătrat
test_chi <- chisq.test(tabel_tip_tiktok)

test_chi
test_chi$expected

# 9. Analiza de corespondență
AC_tip_tiktok <- CA(tabel_tip_tiktok, graph = FALSE)

summary(AC_tip_tiktok)

# 10. Grafic final
fviz_ca_biplot(
  AC_tip_tiktok,
  repel = TRUE,
  col.row = "blue",
  col.col = "red",
  title = "Asocierea dintre tipul de vacanță și utilizarea TikTok/Instagram"
)
