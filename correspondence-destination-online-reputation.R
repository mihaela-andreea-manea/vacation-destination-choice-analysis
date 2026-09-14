# ============================================================
# ANALIZA DE CORESPONDENȚĂ:
# DESTINAȚIE × REPUTAȚIA ONLINE
# ============================================================

library(readxl)
library(FactoMineR)
library(factoextra)

# 1. Importarea datelor
date <- read_excel("data/anonymous-survey-responses.xlsx")

# 2. Selectarea coloanelor pentru reputația online
coloane_reputatie <- grep("^C8\\.", names(date), value = TRUE)

reputatie_destinatii <- date[, coloane_reputatie[2:6]]

# 3. Construirea bazei pentru analiză
destinatii <- c("Barcelona", "Roma", "Atena", "Istanbul", "Budapesta")

date_reputatie <- data.frame(
  destinatie = rep(destinatii, each = nrow(date)),
  reputatie = unlist(reputatie_destinatii)
)

date_reputatie <- na.omit(date_reputatie)

# 4. Recodificarea scalei 1-5
date_reputatie$destinatie <- factor(
  date_reputatie$destinatie,
  levels = destinatii
)

date_reputatie$reputatie <- factor(
  date_reputatie$reputatie,
  levels = c("1", "2", "3", "4", "5"),
  labels = c(
    "Foarte slabă",
    "Slabă",
    "Medie",
    "Bună",
    "Foarte bună"
  )
)

# 5. Tabel de contingență
tabel_destinatie_reputatie <- table(
  date_reputatie$destinatie,
  date_reputatie$reputatie
)

tabel_destinatie_reputatie
addmargins(tabel_destinatie_reputatie)

# 6. Test Chi-pătrat
test_chi <- chisq.test(tabel_destinatie_reputatie)

test_chi
test_chi$expected

# 7. Analiza de corespondență
AC_destinatie_reputatie <- CA(
  tabel_destinatie_reputatie,
  graph = FALSE
)

summary(AC_destinatie_reputatie)

# 8. Grafic final
fviz_ca_biplot(
  AC_destinatie_reputatie,
  repel = TRUE,
  col.row = "blue",
  col.col = "red",
  title = "Asocierea dintre destinație și reputația online"
)
