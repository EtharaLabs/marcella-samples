# Data formats

Every file under /app/data is UTF-8 CSV with a header row. Dates are ISO 8601 (YYYY-MM-DD). Meter readings and
hours are operating hours.

## serial_master.csv

One row per pump serial in the records.

| column | meaning |
| --- | --- |
| serial | pump serial |
| model | HP-450 |
| sb_2307 | Y if SB-2307 is embodied on the pump, else N |

## legacy_import.csv

The pumps fitted to a truck at the 2021-01-04 go-live, loaded from the previous system.

| column | meaning |
| --- | --- |
| serial | pump serial |
| truck | truck the pump was fitted to at go-live |
| installed_on | date the pump was fitted to that truck |
| hours_since_new_at_import | the pump's hours since new at go-live |
| meter_at_import | the truck's meter at go-live |

## installations.csv

One row per fitting of a pump to a truck that is open at or after go-live.

| column | meaning |
| --- | --- |
| install_id | row key |
| source | LEGACY for a fitting loaded from the legacy import (installed_on is then the go-live date and meter_in the truck's meter at go-live); MIS for a fitting recorded in the MIS |
| serial | pump serial |
| truck | truck |
| site | A, B or C |
| installed_on | date fitted |
| meter_in | truck meter at fitting |
| condition | NEW or SERVICEABLE (a pump from stores that has run before); blank for LEGACY rows |
| tsn_at_install | hours since new at fitting, for SERVICEABLE pumps |
| removed_on | date removed; blank while the pump is fitted |
| meter_out | truck meter at removal |
| removal_reason | UNS, PRV or DEC (see fleet.md) |
| removal_wo | the removal work order |

## work_orders.csv

| column | meaning |
| --- | --- |
| wo | work-order key |
| truck | truck |
| date | date of the work |
| meter | truck meter at the work |
| type | PM (1,000 h service), INSTALL (pump fitted), REMOVAL (pump removed) or OTHER (other work on the truck) |
| serial | pump serial, for INSTALL and REMOVAL |
| tasks | task codes separated by semicolons |
| remarks | free text from the work order |

Task codes: PM1000 1,000 h service; FLT-CHG filter change; GRS greasing; BELT belt check; LUBE lubrication;
TYRE-ROT tyre rotation; ELEC-CHK electrical check; BRK-ADJ brake adjustment; CAB-AC cab air conditioning;
INST pump fitted; HOSE-CHK hose check; CASE-DRN case drain check; FLUSH system flush; TORQ fastener torque check;
SB2307 service bulletin SB-2307 embodied; REM-UNS unscheduled pump removal; REM-HT planned pump removal at the
hard-time limit; REM-DEC pump removed from a truck taken out of service; METER-CHG hour meter replaced.

## teardown_reports.csv

| column | meaning |
| --- | --- |
| wo | the removal work order the report refers to |
| vendor | NORTHLINE or KESTREL |
| revision | revision number of the report, 1 for the first issue |
| issued_on | date the revision was issued |
| verdict | CONFIRMED or NFF |
| findings | the vendor's finding |

## telematics_weekly.csv

| column | meaning |
| --- | --- |
| truck | truck |
| week_start | a Monday |
| meter | the truck's meter at 00:00 that Monday |

## vendor_returns.csv

The stores receipts of the pumps the vendors returned, from go-live to the extract.

| column | meaning |
| --- | --- |
| serial | pump serial |
| vendor | NORTHLINE or KESTREL |
| removal_wo | the removal work order of the removal that sent the pump to the vendor; blank for a pump removed before go-live |
| returned_on | date the pump was received into stores |
