# Method: AML MRD by LAIP tracking (ELN 2021)

All FCS files were read with FlowIO and compensated with the spillover matrix in each file's own SPILL keyword. Fluorescence was transformed as arcsinh(x/150). Scatter was used on its linear scale.

## Diagnosis LAIP gates
- Each LAIP is gated inside the laboratory's own anchor gate, taken from the gate file: the CD34 gate (`cd34pos`) when the phenotype contains CD34+, otherwise the CD117 gate (`cd117pos`) when it contains CD117+, otherwise the CD45 white-cell gate (`wbc`).
- The distinguishing markers of the phenotype get one-dimensional thresholds. Backbone CD13+, and CD33+ when another marker is present, were found not to restrict the population and are not gated at diagnosis.
- The threshold is placed so that the LAIP gate contains exactly the number of events the laboratory reported. With two distinguishing markers, both thresholds move together from a common starting cut until the count matches.
- In case_02 the two LAIPs have identical reported counts and form one CD14+ population, so both are gated on CD14 alone.

## Follow-up white-cell, CD34 and CD117 gates
- CD45 white-cell gate: a gradient-boosting classifier trained on the 20 normal donors' laboratory `wbc` gates. Its features are FSC-A, FSC-H, SSC-A, SSC-H, the FSC and SSC area/height ratios (doublets), and CD45. In leave-donor-out tests it matched the laboratory's counts to within about 1-10%.
- CD34 and CD117 gates: classifiers of the same kind, trained on the normal donors' `cd34pos` and `cd117pos` gates within the white-cell gate. Features are scatter, CD45, CD34, CD117, HLA-DR and CD13.
- The CD34 and CD117 gates are subsets of the white-cell gate. BLAST is the union of the two.

## Follow-up LAIP gates
- A LAIP is tracked in every follow-up tube whose panel measures all of its phenotype markers. Its compartment is its diagnostic anchor (CD34, CD117 or WBC).
- Each follow-up LAIP gate starts from the diagnostic gate: the same compartment and the same thresholds. In case_28, follow-up tube P3 carries CD33 on a different fluorochrome; its values are first quantile-mapped onto the CD33 channel of follow-up tube P1.
- Because several LAIP phenotypes also occur on normal cells, a "different-from-normal" step follows, as ELN 2021 recommends. For each LAIP, a classifier separates the diagnostic LAIP cells from the normal donors' cells in the same compartment and panel. It uses the phenotype markers, the anchor marker, CD45 and log SSC.
- Two models are trained, each on half of the donors. Each model's background in normal marrow is measured on the other half.
- The classifier cut-off is the loosest one whose background (90th percentile across held-out donors) is at most 0.01% of white cells. If no cut-off reaches that level, the strictest one is used.
- Follow-up LAIP events are the cells inside the diagnostic LAIP gate whose mean classifier score is above that cut-off.

## Counting
- Tube MRD = 100 * events of the largest LAIP / white cells. The case MRD is the highest tube MRD; the case is POSITIVE at 0.1% or more.
- A tube can support negativity when it has more than 500,000 white cells and its assessed compartment has at least 100 events.
