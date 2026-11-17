# Columns

`stars.csv`: `star_id`, an opaque identifier, one row per star.

`stars/<star_id>.npz`, a NumPy archive with one entry per 2-hour bin in each array:

- `time` (float64, days): TESS barycentric Julian date minus 2457000 (BTJD), the mean mid-time of the FFIs in the bin.
- `sector` (int16): the TESS sector, 14 to 26.
- `flux` (float32, electrons per second, shape bins x 21 x 21): the calibrated pixel flux of the SPOC FFIs, averaged
  over the FFIs in the bin. No background has been subtracted: the sky, including scattered Earth and Moon light, is
  in every pixel. Index `[i, row, column]`; the star is at `[i, 10, 10]`. The cutout follows the detector pixels, so
  its orientation on the sky changes between cameras. Pixels that fall off the detector's science area are 0 and may
  stay 0 for a whole sector.
- `ncad` (int8): the number of 30-minute FFIs averaged in the bin (1 to 4).

How the cutouts were made: for every star and every sector of 14 to 26 that covers it, a 21 x 21 pixel TESScut
(astrocut) cutout of the SPOC-calibrated 30-minute FFIs was centred on the star. FFIs whose quality flag has any of
the bits 1, 2, 4, 8, 32 or 128 set (attitude tweak, safe mode, coarse point, Earth point, momentum dump, manual
exclude) were dropped, and every 4 consecutive FFIs form one bin, averaged over the FFIs that were kept. A sector was
left out when fewer than 90 percent of its bins had a finite flux in the central 3 x 3 pixels. Nothing else was
removed or corrected.
