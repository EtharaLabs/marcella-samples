# Method: rotation periods from TESS FFI pixel cutouts

All code is in /app/scripts (lc.py, build2.py, cbv.py, pgram.py, feat.py, inj.py, inj2.py, real.py, refine.py,
make_output.py); intermediate products are in /app/work. Every period comes from the TESS pixels under /data.
Nothing else was used.

## 1. Light curves from the pixels

Each sector of each star is treated separately (lc.py, sector_lc).

- Bad pixels and cadences: a pixel is used in a sector only if it is finite and non-zero in more than 95 percent
  of that sector's bins. Pixels off the detector (stored as 0) are excluded this way. A bin is kept only if all
  usable pixels are valid in it. A sector is dropped if fewer than 90 percent of its bins have valid central
  3 x 3 pixels, or if the star's excess flux above the background is 5 e-/s or less.
- Background: the background pixels are the usable pixels at least 4 pixels from the star that are fainter than
  the 40th percentile of the median image in that ring. They exclude the star and most neighbouring stars. The
  per-bin background is the median of those pixels, and it is subtracted from every pixel. This removes most of
  the scattered Earth and Moon light, which is spatially smooth.
- Aperture: in the median image, the usable pixels within 2.3 pixels of the star whose background-subtracted flux
  is above 10 percent of the centre pixel's. The aperture flux is divided by the summed median excess of those
  pixels, so each sector is normalised to about 1. I compared this aperture with a smaller one (radius 1.5, 25
  percent threshold), a noise-weighted one and the centre pixel alone. With injected signals this one recovered
  periods best (section 5).
- Outliers: bins where the background is more than 1.6 times the sector median plus 20 e-/s are discarded. These
  are the worst scattered-light episodes, around perigee and at the start of each orbit. Bins more than 6
  robust standard deviations from the sector median are also discarded.

## 2. Instrumental signals

Three kinds of systematics are modelled jointly with the period search, as linear regressors:

1. Common-mode trends (cbv.py). For each sector, I took the cleaned and normalised light curves of all 272 stars,
   subtracted each one's median and divided by its point-to-point scatter. The first principal components of this
   ensemble (singular value decomposition) are the co-trending basis vectors. They carry the pointing jitter,
   focus changes and scattered-light residuals that all stars share at the same times. The first component
   explains 40 to 80 percent of the ensemble variance in each sector. Each star is fitted with its own
   coefficients for the first 4 vectors in each sector. Using more vectors (6, 8 or 12) absorbed real
   long-period signal, and using none left the systematics in (section 5).
2. Background leakage: the star's own background time series, standardised, is one more regressor per sector.
3. Sector-to-sector levels: each 27-day sector uses different pixels and has its own flux level. Fitting a free
   offset per sector would remove most of the power at periods longer than a sector. Instead:
   (a) the level shared by all stars in each sector, the median over stars of the per-sector median flux, is
   divided out. Sectors 20 to 22 are about 2-3 percent low for nearly every star.
   (b) A per-sector offset is still fitted, but with a Gaussian prior of width 0.003 in relative flux (ridge
   regression). Offsets are free only to that extent, so inter-sector jumps are absorbed while a real slow
   modulation survives. 0.003 matches the star-to-star scatter of sector levels after step (a) in the quiet
   sectors.
   The 13.7-day orbit gaps are not filled: each orbit's data simply enter the fit with the regressors above.

Sectors missing for a star are left out. All design matrices are built from the sectors present.

## 3. Period search

pgram.py computes a generalised least-squares periodogram. For each trial frequency, a sine and a cosine are
fitted together with all the regressors above: the systematics model is projected out of the sinusoid columns, not
of the data first. Bins are weighted by the inverse of each sector's point-to-point scatter. The power is the
fractional reduction in weighted chi-square. The trial grid runs from 4 to 150 days, uniform in frequency with
step 1/2160 per day.

The period is chosen as the highest peak between 9 and 110 days, slightly wider than the stated 10 to 100 day
range of the sample. A single sinusoid was used, because adding the second harmonic lowered injection recovery
from 39 to 25 percent at 0.5 percent amplitude. The highest peak is then refined on a grid 20 times finer
(161 frequencies within plus or minus 4 coarse steps).

Two more periodograms are computed in the same way from each half of the data: sectors 14-19 and sectors 20-26.
They are used for the flag.

## 4. Uncertainty

period_err_days = max(0.25 x P^2 x HWHM, 0.005 x P), where HWHM is the half-width at half-maximum of the refined
peak in frequency. I calibrated the factor 0.25 with injections: for correctly recovered injected periods, the
68th percentile of |P_found - P_true| / (P^2 HWHM) was 0.22. The floor of 0.5 percent of P covers differential
rotation and spot evolution, which make any single-season period uncertain at about that level.

## 5. Checks without known periods (injection and recovery)

No true period is given, so every choice was tested by multiplying synthetic signals into the real light curves
of all 272 stars. The real noise and systematics stay in place. The injected periods are log-uniform between 10
and 100 days.

- Sinusoids of 0.5 percent amplitude, used for tuning (inj.py), recovered within 10 percent:
  8 vectors 39%, 12 vectors 35%, 6 vectors 47%, 4 vectors 55%, 3 vectors 55%, 2 vectors 52%, no vectors 31%,
  8 vectors without background regressor 38%, 8 vectors with 2 harmonics 25%. Then with 4 vectors: offset prior
  plus common sector level 57%, large aperture 59%, large aperture plus offset prior 59%, centre pixel only 18%.
  At 1 percent amplitude, the 8-vector version already recovered 74%.
  The adopted pipeline (4 vectors, large aperture, common level, offset prior 0.003) recovers 83% of these
  injections at 10-20 d, 70% at 20-40 d, 33% at 40-70 d and 25% at 70-100 d.
- Spot-like signals (inj2.py), used for the flag and error calibration: amplitude log-uniform from 0.2 to 3
  percent, a second harmonic with random relative amplitude 0 to 0.6, and an amplitude envelope varying on 1 to 5
  rotations to mimic spot evolution. Two random seeds, 544 injections. 62 percent were recovered overall.
  In 27 percent of the injections the highest peak was the star's own real-data peak rather than the injected
  one, which is not an error for the real task. Excluding those cases, the precision was:
  both halves agree 97%, exactly one half agrees 77%, one half agrees and power > 0.1 82%, neither half agrees 39%.
- Common-mode residuals: the real-data periods show no pile-up at 13.7 or 27 days. There is a mild excess at 31
  to 35 days (37 stars). For those stars I fitted a 32.5-day sinusoid to the detrended light curves. The phases
  in calendar time are uniform (Rayleigh R = 0.02, against 0.16 expected by chance). So the excess is not a
  systematic shared across stars at the same times. It may still contain some star-specific residual offsets.
- The light curves were also inspected numerically, in 2-day bins per sector, next to the background. That is how
  the scattered-light ramps at the orbit starts and the low levels of sectors 20-22 were found.

## 6. Flag

flag = 1 if the peak period (9-110 d) of at least one half of the data (sectors 14-19 or 20-26) agrees within 10
percent with the full-data period, and either both halves agree or the full-data peak power exceeds 0.07.
Otherwise flag = 0.

This flags 157 of 272 stars (57.7 percent): 95 where both halves agree and 62 where one half agrees with enough
power. From the injection precision above, about 85 to 90 percent of the flagged periods should be the dominant
signal of the star. Agreement with the ground-based period will be somewhat lower where TESS finds half the
true period (double-dipped light curves) or where a residual systematic dominates. Unflagged stars still get the
highest peak as their period, but their precision is about 40 to 75 percent in the injection tests.

## 7. Known limitations

- Periods above about 40 days are recovered poorly, because each sector is only about 27 days long and the
  sector offsets are only partly constrained.
- Half-period aliases (the periodogram peaking at P/2) are not corrected, because the data offer no way to test
  any correction.
- The flag threshold of 0.07 was chosen so that more than 50 percent of stars are flagged, with an estimated
  precision well above 75 percent. The estimate comes from injections, not from known periods.
