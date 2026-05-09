# R/batch_plots.R
# Generate a curated PNG gallery of example traces (~24 fruits, two per trial).

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
})

source("R/process.R")
traces <- readRDS("data/traces.rds")

dir.create("figures/traces", showWarnings = FALSE, recursive = TRUE)

set.seed(42)
gallery <- traces |>
  dplyr::distinct(trial, trial_no, fruit) |>
  dplyr::group_by(trial) |>
  dplyr::slice_sample(n = 2) |>
  dplyr::ungroup()

for (i in seq_len(nrow(gallery))) {
  fid <- gallery$fruit[i]
  p <- plot_trace(traces, fruit_id = fid, trace_no = fid)
  fname <- sprintf("figures/traces/Plot_Fruit_%03d.png", fid)
  ggsave(fname, p, width = 6.5, height = 3.2, dpi = 150)
}

cat(sprintf("Wrote %d trace plots to figures/traces/\n", nrow(gallery)))
