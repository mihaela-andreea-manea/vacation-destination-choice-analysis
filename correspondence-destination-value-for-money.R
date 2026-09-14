# ============================================================
# ANALIZA DE CORESPONDENȚĂ:
# DESTINAȚIE × RAPORT CALITATE-PREȚ
# ============================================================

library(readxl)
library(FactoMineR)
library(factoextra)

# 1. Importarea datelor
date <- read_excel("anonymous-survey-responses.xlsx")

# 2. Selectarea coloanelor pentru raport calitate-preț
coloane_calitate_pret <- grep("^C5\\.", names(date), value = TRUE)

calitate_pret_destinatii <- date[, coloane_calitate_pret[2:6]]

# 3. Construirea bazei pentru analiză
destinatii <- c("Barcelona", "Roma", "Atena", "Istanbul", "Budapesta")

date_calitate_pret <- data.frame(
  destinatie = rep(destinatii, each = nrow(date)),
  calitate_pret = unlist(calitate_pret_destinatii)
)

date_calitate_pret <- na.omit(date_calitate_pret)

# 4. Recodificarea scalei 1-5
date_calitate_pret$destinatie <- factor(
  date_calitate_pret$destinatie,
  levels = destinatii
)

date_calitate_pret$calitate_pret <- factor(
  date_calitate_pret$calitate_pret,
  levels = c("1", "2", "3", "4", "5"),
  labels = c(
    "Foarte slab",
    "Slab",
    "Mediu",
    "Bun",
    "Foarte bun"
  )
)

# 5. Tabel de contingență
tabel_destinatie_calitate_pret <- table(
  date_calitate_pret$destinatie,
  date_calitate_pret$calitate_pret
)

tabel_destinatie_calitate_pret
addmargins(tabel_destinatie_calitate_pret)

# 6. Test Chi-pătrat
test_chi <- chisq.test(tabel_destinatie_calitate_pret)

test_chi
test_chi$expected

# 7. Analiza de corespondență
AC_destinatie_calitate_pret <- CA(
  tabel_destinatie_calitate_pret,
  graph = FALSE
)

summary(AC_destinatie_calitate_pret)

# 8. Grafic final
fviz_ca_biplot(
  AC_destinatie_calitate_pret,
  repel = TRUE,
  col.row = "blue",
  col.col = "red",
  title = "Asocierea dintre destinație și raportul calitate-preț"
)
