# Apple firmness — vibration-trace processing

Portfolio piece — a synthetic recreation of a non-destructive
**vibration-based firmness** measurement pipeline I built during a
fruit-quality project. Two-channel waveforms (stem end & calyx end),
minimum detection, batch QA plots, and a `CH1 × CH2` summary scatter.

[![Live report](https://img.shields.io/badge/Live-report-blue?logo=github)](https://uta666xyz.github.io/apple-firmness-traces/)

The original waveforms are not shareable, so the included data is
simulated with a damped Gabor wavelet plus a small initial transient
and additive Gaussian noise. The qualitative shape and the trial-level
drift mirror what I observed on the real instrument.

## What's here

* `R/simulate.R` — generates `data/traces.rds`
  (13 trials × 8 fruits × 2 channels, sampled at 50 kHz over 2 ms).
* `R/process.R` — `detect_min()` (smoothed argmin), `summarise_traces()`,
  and `plot_trace()` (ggplot grey-theme replica with orange/green
  vertical bars at the detected minima).
* `R/batch_plots.R` — writes ~26 per-fruit PNGs to `figures/traces/`.
* `analysis.Rmd` — knit to a self-contained HTML report containing
  example traces, the CH1 × CH2 scatter coloured by trial, and the
  trial-level `t_min` drift plot.

## Reproducing

```r
install.packages(c("ggplot2", "dplyr", "tidyr", "rmarkdown"))
source("R/simulate.R")              # writes data/traces.rds
source("R/batch_plots.R")           # writes figures/traces/*.png
rmarkdown::render("analysis.Rmd")   # writes analysis.html + figures/*.png
```

## What the figures show

* **Per-trace plots** — two channels (CH1 stem-end red, CH2 calyx-end
  cyan), each annotated with a vertical bar at its detected minimum.
* **CH1 × CH2 scatter** — most fruits sit near the diagonal; vertical
  excursions are CH2-only outliers. Trials cluster along the diagonal
  by ripening / storage stage.
* **Drift by trial** — median `t_min` increases monotonically across
  the sampling window as fruit softens.

## Disclaimer

Numbers are simulated. The repo demonstrates **the processing
workflow** (signal → minimum detection → per-trace QA → batch
summary), not a biological finding.
