# ============================================================
# ANALIZA DE CORESPONDENȚĂ:
# DESTINAȚIE × COST TOTAL PERCEPUT
# ============================================================

library(readxl)
library(dplyr)
library(FactoMineR)
library(factoextra)

# 1. Importarea datelor
date <- read_excel("anonymous-survey-responses.xlsx")

# 2. Coloanele pentru costul total perceput
cost_destinatii <- date[, c(
  "C1. Cât de avantajos vi se pare costul total pentru 5–7 zile în locațiile de mai jos?\r\n(1 = deloc avantajos/foarte scump, 5 = foarte avantajos/foarte accesibil) [Barcelona]",
  "C1. Cât de avantajos vi se pare costul total pentru 5–7 zile în locațiile de mai jos?\r\n(1 = deloc avantajos/foarte scump, 5 = foarte avantajos/foarte accesibil) [Roma ]",
  "C1. Cât de avantajos vi se pare costul total pentru 5–7 zile în locațiile de mai jos?\r\n(1 = deloc avantajos/foarte scump, 5 = foarte avantajos/foarte accesibil) [Atena]",
  "C1. Cât de avantajos vi se pare costul total pentru 5–7 zile în locațiile de mai jos?\r\n(1 = deloc avantajos/foarte scump, 5 = foarte avantajos/foarte accesibil) [Istanbul]",
  "C1. Cât de avantajos vi se pare costul total pentru 5–7 zile în locațiile de mai jos?\r\n(1 = deloc avantajos/foarte scump, 5 = foarte avantajos/foarte accesibil) [Budapesta]"
)]

# 3. Baza pentru analiză
destinatii <- c("Barcelona", "Roma", "Atena", "Istanbul", "Budapesta")

date_cost <- data.frame(
  destinatie = rep(destinatii, each = nrow(date)),
  cost = unlist(cost_destinatii)
)

date_cost <- na.omit(date_cost)

# 4. Recodificarea scalei 1-5
date_cost$destinatie <- factor(date_cost$destinatie, levels = destinatii)

date_cost$cost <- factor(
  date_cost$cost,
  levels = c("1", "2", "3", "4", "5"),
  labels = c(
    "Foarte scump",
    "Scump",
    "Mediu",
    "Accesibil",
    "Foarte accesibil"
  )
)

# 5. Tabel de contingență
tabel_destinatie_cost <- table(date_cost$destinatie, date_cost$cost)

tabel_destinatie_cost
addmargins(tabel_destinatie_cost)

# 6. Test Chi-pătrat
test_chi <- chisq.test(tabel_destinatie_cost)

test_chi
test_chi$expected

# 7. Analiza de corespondență
AC_destinatie_cost <- CA(tabel_destinatie_cost, graph = FALSE)

summary(AC_destinatie_cost)

# 8. Grafic final
fviz_ca_biplot(
  AC_destinatie_cost,
  repel = TRUE,
  col.row = "blue",
  col.col = "red",
  title = "Asocierea dintre destinație și costul total perceput"
)
