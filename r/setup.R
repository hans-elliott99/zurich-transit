
cat("setup: Installing necessary R packages.\n")

if (!("pacman" %in% rownames(installed.packages()))) install.packages("pacman") 
for (pkg in c("dplyr", "readr", "here", "magrittr", "arrow")) {
  if (!pacman::p_isinstalled(pkg)) {
    install.packages(pkg)
  }
}
