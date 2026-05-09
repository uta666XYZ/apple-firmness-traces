# R/process.R
# Detect the global minimum of each channel trace and provide a plot helper
# matching the original ggplot grey-theme + colored vertical-bar style.

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
})

# light smoothing to suppress noise before argmin
smooth_signal <- function(y, k = 5) {
  if (k < 2) return(y)
  w <- rep(1 / k, k)
  as.numeric(stats::filter(y, w, sides = 2))
}

detect_min <- function(time_s, signal, smooth_k = 5) {
  s <- smooth_signal(signal, smooth_k)
  idx <- which.min(s)
  list(t_min = time_s[idx], y_min = signal[idx], idx = idx)
}

# returns one row per (fruit, channel) with t_min in milliseconds
summarise_traces <- function(traces) {
  traces |>
    tidyr::pivot_longer(c(CH1, CH2), names_to = "channel", values_to = "signal") |>
    dplyr::group_by(trial, trial_no, fruit, channel) |>
    dplyr::summarise(
      t_min_ms = detect_min(time_s, signal)$t_min * 1000,
      y_min    = detect_min(time_s, signal)$y_min,
      .groups  = "drop"
    )
}

plot_trace <- function(traces, fruit_id, trace_no = fruit_id) {
  d <- traces[traces$fruit == fruit_id, ]
  if (nrow(d) == 0) stop("no rows for fruit ", fruit_id)

  m1 <- detect_min(d$time_s, d$CH1)
  m2 <- detect_min(d$time_s, d$CH2)

  long <- tidyr::pivot_longer(d, c(CH1, CH2),
                              names_to = "Channel", values_to = "Signal")
  long$Channel <- factor(long$Channel,
                         levels = c("CH1", "CH2"),
                         labels = c("CH1 Stem end", "CH2 Blossom end"))

  ggplot(long, aes(time_s * 1000, Signal, colour = Channel)) +
    geom_line(linewidth = 0.4) +
    geom_vline(xintercept = m1$t_min * 1000, colour = "orange",
               linewidth = 0.8) +
    geom_vline(xintercept = m2$t_min * 1000, colour = "forestgreen",
               linewidth = 0.8) +
    scale_colour_manual(values = c("CH1 Stem end" = "#E41A1C",
                                   "CH2 Blossom end" = "#00BFC4")) +
    scale_x_continuous(limits = c(0, 2), expand = c(0, 0)) +
    labs(x = "Time (ms)", y = "Signal (A.U.)",
         title = sprintf("Fruit No.%d, Trace No.%d",
                         fruit_id, trace_no)) +
    theme_grey(base_size = 11) +
    theme(legend.position = "right",
          panel.grid.minor = element_blank())
}
