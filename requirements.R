packages <- c(
  "readxl",
  "dplyr",
  "tidyr",
  "ggplot2",
  "scales",
  "forcats",
  "FactoMineR",
  "factoextra",
  "stringr"
)

missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

