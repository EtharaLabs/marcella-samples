# Method

The FFI flux still carries scattered light and pointing systematics on the 13.7-day orbit and the 27-day sector, so a periodogram of the aperture flux finds the orbit, not the star. The systematics are shared by many pixels of the cutout while the star's spot modulation is not, so the script removes what distant pixels can predict and then searches for a sinusoid while letting every sector have its own flux level. Every period is measured from the shipped TESS pixels; no other data are used.

1. Missing and zero data: a sector is dropped when any of the central 5 x 5 pixels has a median flux of 0 or less (the star on or next to non-science pixels). Pixels that are not finite in every bin of a sector, or whose median is 0 or less, are never used as targets or predictors.
2. Light curve and de-trending, one sector at a time, follow the causal pixel model of the unpopular package (Hattori et al. 2022). Each of the central 3 x 3 pixels is divided by its median and has 1 subtracted. Its predictors are the 128 pixels, outside the 5 x 5 block around it, whose median flux is closest to its own. A ridge regression (penalty 0.01) predicts the pixel. The sector is cut into 50 contiguous sections, and each section is predicted by a model fit to the other 49, so the model never sees the data it removes. The 9 residuals, weighted back by their medians, are summed into a fractional light curve.
3. The period search is the offset-corrected least-squares periodogram of Hattori et al. (2025): for each of 5,000 trial periods evenly spaced from 10 to 100 days, a sine, a cosine and one constant per sector are fitted, and the power is the fraction of the variance about the sector means that the sinusoid removes. The free constant per sector absorbs the flux jumps between sectors.
4. Choosing one period: the highest peak, as in the published method. There is no half-or-double correction, so a double-humped spot signal, which puts the highest peak at half the rotation period, is one way the method can miss.
5. The uncertainty `period_err_days` is the half width at half maximum of the chosen peak, and at least the grid step.
6. Flag: `flag` is 1 when the highest power is at least 0.02, the threshold of Hattori et al. (2025), and 0 otherwise.

Checking the method: every setting above is the published one (Hattori et al. 2022 and 2025), so nothing was tuned on known periods. No star's period is given, so no accuracy can be measured here, and none is claimed.

Every step is deterministic (no random numbers, one thread), so the output is byte-identical between runs.
