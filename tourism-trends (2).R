# =========================================================
# EVOLUTIA TURISMULUI IN EUROPA
# Analiza descriptiva pe baza datelor Eurostat
# Sheet utilizat: Date_curat
# =========================================================

# ---------------------------------------------------------
# 0. Pachete necesare
# ---------------------------------------------------------
# Daca nu le ai instalate, ruleaza o singura data:
# install.packages(c("readxl", "dplyr", "tidyr", "ggplot2", "scales", "forcats"))

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(forcats)

# ---------------------------------------------------------
# 1. Citirea datelor din Excel
# ---------------------------------------------------------
# Se foloseste fisierul inclus in repository si sheet-ul "Date_curat".

date_tari <- read_excel(
  "eurostat-tourism-data.xlsx",
  sheet = "Date_curat"
)

# Verificare rapida a datelor
head(date_tari)
names(date_tari)
str(date_tari)

# ---------------------------------------------------------
# 2. Transformarea datelor in format lung
# ---------------------------------------------------------
# In fisier, anii sunt pe coloane.
# Pentru grafice, este mai usor sa lucram cu:
# GEO | an | nights

date_tari_long <- date_tari %>%
  pivot_longer(
    cols = -GEO,
    names_to = "an",
    values_to = "nights"
  ) %>%
  mutate(
    an = as.numeric(an),
    nights = as.numeric(nights)
  )

head(date_tari_long)

# ---------------------------------------------------------
# 3. Construirea indicelui 2019 = 100
# ---------------------------------------------------------
# Acest indice ne ajuta sa comparam tarile intre ele,
# chiar daca ele au dimensiuni turistice foarte diferite.
#
# Formula este:
# indice_2019 = (valoarea din anul t / valoarea din 2019) * 100
#
# Daca indicele este:
# - 100 -> tara este exact la nivelul din 2019
# - peste 100 -> tara a depasit nivelul pre-pandemic
# - sub 100 -> tara nu a revenit inca la nivelul din 2019

date_indice <- date_tari_long %>%
  group_by(GEO) %>%
  mutate(
    indice_2019 = nights / nights[an == 2019] * 100
  ) %>%
  ungroup()

# =========================================================
# GRAFICUL 1
# Evolutia medianei numarului de innoptari turistice in Europa
# =========================================================
# CE ARATA:
# Acest grafic surprinde evolutia "tendintei centrale" in Europa.
# Folosim mediana, nu media, pentru ca mediana este mai putin influentata
# de tarile foarte mari turistic.
#
# CUM IL INTERPRETEZI:
# - daca linia urca -> in general, turismul european creste
# - daca linia scade puternic in 2020 -> se vede impactul pandemiei
# - daca dupa 2021 urca din nou -> se vede redresarea

mediana_anuala <- date_tari_long %>%
  group_by(an) %>%
  summarise(mediana_nights = median(nights, na.rm = TRUE))

ggplot(mediana_anuala, aes(x = an, y = mediana_nights)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_y_continuous(labels = label_number(big.mark = " ", decimal.mark = ",")) +
  labs(
    title = "Tendinta centrala a innoptarilor turistice in Europa (2005–2024)",
    x = "An",
    y = "Mediana innoptarilor"
  ) +
  theme_minimal()

# =========================================================
# GRAFICUL 2
# Distributia numarului de innoptari turistice pe ani
# =========================================================
# CE ARATA:
# Acest boxplot arata cum sunt distribuite valorile pentru toate tarile
# in fiecare an.
#
# CUM IL INTERPRETEZI:
# - cutia arata zona in care se afla majoritatea tarilor
# - liniile si punctele extreme arata diferentele intre tari
# - daca intreaga distributie coboara in 2020, inseamna ca pandemia
#   a afectat aproape toate statele
# - daca dupa 2021 cutiile urca din nou, inseamna ca turismul se redreseaza

ggplot(date_tari_long, aes(x = factor(an), y = nights)) +
  geom_boxplot() +
  scale_y_continuous(labels = label_number(big.mark = " ", decimal.mark = ",")) +
  labs(
    title = "Distributia numarului de innoptari turistice in Europa, pe ani",
    x = "An",
    y = "Numar de innoptari"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =========================================================
# GRAFICUL 3
# Evolutia mediei anuale a indicelui 2019 = 100
# =========================================================
# CE ARATA:
# Acest grafic arata, la nivel general, cum s-au pozitionat tarile
# fata de anul 2019, considerat an de referinta pre-pandemic.
#
# CUM IL INTERPRETEZI:
# - linia 100 reprezinta nivelul din 2019
# - sub 100 = in medie, tarile nu au revenit la nivelul pre-pandemic
# - peste 100 = in medie, tarile au depasit nivelul din 2019
# - caderea puternica in 2020 arata socul pandemiei
# - revenirea ulterioara arata redresarea turismului

medie_indice_anuala <- date_indice %>%
  group_by(an) %>%
  summarise(media_indice_2019 = mean(indice_2019, na.rm = TRUE))

ggplot(medie_indice_anuala, aes(x = an, y = media_indice_2019)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_hline(yintercept = 100, linetype = "dashed") +
  labs(
    title = "Evolutia turismului european in raport cu nivelul din 2019",
    x = "An",
    y = "Media indicelui (2019 = 100)"
  ) +
  theme_minimal()

# =========================================================
# GRAFICUL 4
# Evolutia comparativa a principalelor 5 tari turistice europene
# =========================================================
# CE ARATA:
# Mai intai alegem primele 5 tari dupa numarul de innoptari din 2019,
# adica cele mai importante tari turistice inainte de pandemie.
# Apoi le urmarim evolutia in timp prin indicele 2019 = 100.
#
# CUM IL INTERPRETEZI:
# - fiecare linie arata ritmul de scadere si de revenire pentru o tara
# - vezi care tari au fost mai afectate
# - vezi care tari si-au revenit mai repede
# - este mai bun decat un grafic pe valori absolute,
#   pentru ca poti compara ritmuri, nu doar marimi

top5_tari <- date_tari_long %>%
  filter(an == 2019) %>%
  arrange(desc(nights)) %>%
  slice(1:5) %>%
  pull(GEO)

top5_indice <- date_indice %>%
  filter(GEO %in% top5_tari)

ggplot(top5_indice, aes(x = an, y = indice_2019, color = GEO)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.8) +
  labs(
    title = "Evolutia comparativa a principalelor 5 tari turistice europene (2019 = 100)",
    x = "An",
    y = "Indice (2019 = 100)",
    color = "Tara"
  ) +
  theme_minimal()

# =========================================================
# GRAFICUL 5
# Recuperarea turismului in 2024 fata de nivelul din 2019
# =========================================================
# CE ARATA:
# Acest grafic clasifica toate tarile in functie de recuperarea
# activitatii turistice in 2024 fata de 2019.
#
# CUM IL INTERPRETEZI:
# - linia 100 inseamna nivelul din 2019
# - daca o tara este peste 100, atunci in 2024 a depasit nivelul pre-pandemic
# - daca este sub 100, inseamna ca nu a recuperat complet
# - este un grafic foarte bun pentru concluzii comparative

recuperare_2024 <- date_indice %>%
  filter(an == 2024) %>%
  arrange(desc(indice_2019))

ggplot(recuperare_2024, aes(x = fct_reorder(GEO, indice_2019), y = indice_2019)) +
  geom_col() +
  coord_flip() +
  geom_hline(yintercept = 100, linetype = "dashed") +
  labs(
    title = "Recuperarea turismului in 2024 fata de nivelul din 2019",
    x = "Tara",
    y = "Indice (2019 = 100)"
  ) +
  theme_minimal()


# =========================================================
# 4. TABELE UTILE PENTRU INTERPRETARE
# =========================================================

# Tabel 1 - mediana anuala
mediana_anuala

# Tabel 2 - media anuala a indicelui 2019 = 100
medie_indice_anuala

# Tabel 3 - primele 5 tari turistice in 2019
top5_tari

# Tabel 4 - recuperarea tuturor tarilor in 2024 fata de 2019
recuperare_2024
