# ============================================================
# ANALIZA DE CORESPONDENȚĂ:
# VENIT LUNAR × NUMĂR DE CITY-BREAK-URI / CĂLĂTORII EXTERNE
# ============================================================

# 1. Instalare pachete, dacă nu sunt deja instalate
#install.packages("readxl")
#install.packages("FactoMineR")
#install.packages("factoextra")

# 2. Încărcare pachete
library(readxl)
library(FactoMineR)
library(factoextra)

# 3. Importarea bazei de date
date <- read_excel("anonymous-survey-responses.xlsx")

# 4. Verificarea numelor coloanelor
names(date)

# 5. Selectarea variabilelor analizate
venit <- date$`Care este venitul dumneavoastră lunar(aproximativ, net)?`

citybreak <- date$`Câte călătorii externe aveți în medie pe an?`

# 6. Transformarea variabilelor în factori
venit <- as.factor(venit)
citybreak <- as.factor(citybreak)

# 7. Construirea tabelului de contingență
tabel_venit_city <- table(venit, citybreak)

# 8. Afișarea tabelului de contingență
tabel_venit_city

# 9. Aplicarea testului Chi-pătrat
test_chi <- chisq.test(tabel_venit_city)

# 10. Afișarea rezultatului testului Chi-pătrat
test_chi

# 11. Afișarea valorii p
test_chi$p.value

# 12. Verificarea semnificației statistice
if (test_chi$p.value < 0.05) {
  print("Relația dintre venit și numărul de city-break-uri este semnificativă statistic.")
} else {
  print("Relația dintre venit și numărul de city-break-uri NU este semnificativă statistic.")
}

# 13. Afișarea valorilor așteptate
test_chi$expected

# 14. Analiza de corespondență
ca_venit_city <- CA(tabel_venit_city, graph = FALSE)

# 15. Rezumatul analizei de corespondență
summary(ca_venit_city)

# 16. Graficul analizei de corespondență
fviz_ca_biplot(ca_venit_city,
               repel = TRUE,
               title = "Analiza de corespondență: venit lunar și număr de city-break-uri")

# 17. Grafic mai curat pentru lucrare
fviz_ca_biplot(ca_venit_city,
               repel = TRUE,
               col.row = "blue",
               col.col = "red",
               title = "Asocierea dintre venit și frecvența călătoriilor externe")
