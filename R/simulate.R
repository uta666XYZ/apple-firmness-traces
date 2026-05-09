# R/simulate.R
# Synthetic vibration-trace generator for the apple firmness portfolio.
#
# Each "trace" is a damped Gabor-like waveform with a small initial transient
# and additive noise. Two channels (CH1 = stem end, CH2 = calyx end) are
# generated per fruit. Multiple trials sampled across a storage window give
# the dataset its time structure (firmer early -> softer late => later t_min).

set.seed(20240501)

dir.create("data", showWarnings = FALSE)

# -- design ------------------------------------------------------------------
trials <- c("Sep-18", "Oct-18", "Nov-18", "Dec-18", "Jan-19",
            "Feb-19", "Mar-19", "Apr-19", "May-19", "Jun-19",
            "Jul-19", "Sep-19", "Oct-19")
n_fruit_per_trial <- 8
fs    <- 50000                              # 50 kHz sampling
t_max <- 0.002                              # 2 ms window
t     <- seq(0, t_max, by = 1 / fs)

# trial-level firmness drift: earlier trials => earlier minimum (firmer fruit)
trial_t_center_ch1 <- seq(0.55e-3, 0.95e-3, length.out = length(trials))
trial_t_center_ch2 <- trial_t_center_ch1 + 0.04e-3   # blossom end slightly later

make_trace <- function(t, t_center, A = 1, sigma = 0.18e-3, f = 1800,
                       transient_amp = 0.15, noise_sd = 0.02) {
  envelope  <- exp(-((t - t_center) ^ 2) / (2 * sigma ^ 2))
  carrier   <- cos(2 * pi * f * (t - t_center))
  main      <- -A * envelope * carrier
  transient <- transient_amp * exp(-t / 0.0001) * sin(2 * pi * 6000 * t)
  main + transient + rnorm(length(t), sd = noise_sd)
}

# -- generate ----------------------------------------------------------------
records <- list()
fruit_id <- 0L

for (i in seq_along(trials)) {
  for (k in seq_len(n_fruit_per_trial)) {
    fruit_id <- fruit_id + 1L

    jitter1 <- rnorm(1, 0, 0.04e-3)
    jitter2 <- rnorm(1, 0, 0.04e-3)
    # occasional vertical outlier on CH2 (mirrors original "Skin 2018-2019")
    if (runif(1) < 0.07) jitter2 <- jitter2 + runif(1, 0.10e-3, 0.18e-3)

    ch1 <- make_trace(t, t_center = trial_t_center_ch1[i] + jitter1,
                      A = runif(1, 0.85, 1.10),
                      f = rnorm(1, 1800, 60))
    ch2 <- make_trace(t, t_center = trial_t_center_ch2[i] + jitter2,
                      A = runif(1, 0.80, 1.05),
                      f = rnorm(1, 1750, 60))

    records[[length(records) + 1L]] <- data.frame(
      trial    = trials[i],
      trial_no = i,
      fruit    = fruit_id,
      time_s   = t,
      CH1      = ch1,
      CH2      = ch2
    )
  }
}

traces <- do.call(rbind, records)
traces$trial <- factor(traces$trial, levels = trials)

saveRDS(traces, "data/traces.rds")
cat(sprintf("Wrote data/traces.rds: %d fruits x %d samples = %d rows\n",
            fruit_id, length(t), nrow(traces)))
