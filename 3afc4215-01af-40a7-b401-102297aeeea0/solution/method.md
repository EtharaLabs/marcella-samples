# Method

Each reflector's apex is a point target. Its position in an image gives one zero-Doppler time and one slant range;
with the orbit and the apex height that fixes a ground point. At L-band the measured range is longer than the
geometric range by the ionospheric and tropospheric delays, so the range is corrected before geolocation.

1. **Peak.** For every chip, the brightest pixel is found, a 32 x 32 window around it is basebanded (the mean phase
   step along each axis removed), Fourier transformed, zero-padded 32 times and transformed back; the peak of the
   oversampled magnitude, refined by a parabola through it and its neighbours, gives the sub-pixel line and sample.
   The chip's `zeroDopplerTime` and `slantRange` vectors turn these into the time and range of the apex.
2. **Orbit.** Position and velocity at that time from cubic Hermite interpolation of the product's state vectors
   (positions and velocities, 10 s apart; the product states `Hermite`).
3. **Geolocation.** The apex lies in the zero-Doppler plane (perpendicular to the Earth-fixed velocity), at the
   corrected slant range from the antenna, to the left of the track (`lookDirection` = Left), at its height above the
   WGS84 ellipsoid from `reflectors.csv`; the look angle in that plane is found by bisection on the height.
4. **Ionosphere.** Group delay 40.3 TEC / f^2 at the processed centre frequency (1.239 GHz). The IGS map gives the
   vertical TEC at the pierce point of the line of sight on the 450 km shell of the IONEX header, interpolated in
   time between the two-hourly maps rotated with the Sun; slant TEC is the vertical TEC times the thin-shell mapping
   1/cos z'. The map integrates electrons up to the GPS orbit (about 20,200 km), but NISAR flies at about 747 km, so
   the electrons above the satellite do not delay its signal. I remove a topside and plasmaspheric content of
   6.6 TECU above the satellite, the value Yunjun et al. (2022) measured for an L-band satellite, before mapping.
5. **Troposphere.** The processing record of every product (`runConfigurationContents`) shows
   `dry_troposphere_model: tsx`: the focusing already removed a dry delay of 2.3 m exp(-h / 6 km) / cos(incidence)
   (the TerraSAR-X model in ISCE3). From the Edwards AFB weather, interpolated to the acquisition time, I compute the
   pressure at the apex height from the altimeter setting, the Saastamoinen hydrostatic zenith delay and the
   Saastamoinen wet zenith delay from the dew point and temperature, subtract the dry delay already removed, and map
   the remainder with 1/cos(incidence). Adding the full troposphere would count the dry delay twice.
6. **Tides and plate motion.** The solid Earth tide moves the apex by up to about 20 cm along the line of sight on a
   given date but averages to under 5 cm per track over these dates, and the reflectors move under 3 cm over the
   period, so neither is modelled.
7. **Combination.** Every corrected (time, range) pair is geolocated; each reflector's position is the median
   latitude and longitude over all its acquisitions (24 from the descending track, or 49 from the two ascending
   tracks). The median absorbs the acquisitions whose along-track timing is off by 1 to 4 m (about one in four).

No accuracy is claimed against the surveyed positions, which are sealed.
