# Definitions for the HP-450 pump reliability study

## Lives

**Hours since new.** The operating hours a pump has run since it was new, summed over every truck it has been
fitted to.

**Life.** The record of one pump serial, from the hours since new at which it comes under observation (entry) to
the hours since new at which observation of it ends (exit). A pump fitted new enters at 0 h. A pump that was
already fitted at the 2021-01-04 go-live enters at its hours since new at go-live.

**Teardown verdict.** The verdict of an unscheduled removal's teardown report as it stands at the extract.

**Confirmed failure.** An unscheduled removal whose teardown verdict is CONFIRMED. A life ends at its confirmed
failure (event 1).

**Suspension.** A life that ends without a confirmed failure (event 0): at a hard-time removal, at the last removal
of a pump that is not refitted by the extract, or at the extract for a pump still fitted then.

**NFF removal.** An unscheduled removal whose teardown verdict is NFF (no fault found).

## Estimates

**Life distribution.** The two-parameter Weibull distribution of hours since new to confirmed failure,
F(t) = 1 - exp(-(t / eta)^beta), fitted by maximum likelihood over the lives, with the confirmed failure as the
event and every other end a suspension. Each life's likelihood contribution is conditional on survival to its entry
hours.

**B10.** The hours since new by which 10 percent of pumps fail under the fitted distribution,
eta (-ln 0.9)^(1/beta).

**SB-2307 hazard ratio.** The ratio of the hazard of confirmed failure of a pump with SB-2307 embodied to the hazard
of an unmodified pump at the same hours since new, under proportional hazards in hours since new.

## Forecast

**Extract.** Monday 2026-09-28. The telematics reading dated 2026-09-28 is each truck's meter at the extract. The
fitted fleet is the set of pumps fitted to a truck at the extract.

**Utilisation.** A truck's mean operating hours per week over the 13 complete weeks before the extract, the weeks
from Monday 2026-06-29 to the extract.

**Window.** The 26 weeks after the extract. Each pump of the fitted fleet runs at its truck's utilisation from its
hours since new at the extract.

**E26.** The expected number of confirmed failures in the window among the pumps of the fitted fleet.

**Queue time.** The time from a pump's removal to its return to stores by the vendor.

**Due back.** A pump at a vendor at the extract is due back to stores if it was removed from a truck taken out of
service or its teardown verdict is NFF.

**Spares level S95.** In the window stores issue one pump to a truck each time a fitted pump is removed from it, and
take in each pump due back when the vendor returns it. A pump removed in the window does not return to stores within
the window, and a pump that stores issue in the window is not removed again within it, so each pump of the fitted
fleet draws at most one pump from stores. S95 is the smallest number of pumps held in stores at the extract for which,
with probability at least 0.95, stores have a pump to issue at every removal in the window.

## Conventions

- **C1.** E26 is a crude incidence: a pump that has an NFF removal or reaches the hard-time limit in the window
  before it fails does not count as a confirmed failure in the window.
- **C2.** S95 is the plug-in level: it is computed at the maximum-likelihood estimates, with the pumps of the fitted
  fleet removed independently of each other, and each pump due back returned independently of the removals and of
  the other returns, at the queue times its vendor has shown since go-live and as the vendor's notices set out.
- **C3.** NFF removals occur at a constant rate per operating hour, independently of failure.
- **C4.** An unscheduled removal whose teardown report has not been issued by the extract is a suspension at its
  removal hours, and its pump is not due back.
- **C5.** E26 and S95 use the fleet life distribution (beta, eta) for every pump, whatever its SB-2307 status.
