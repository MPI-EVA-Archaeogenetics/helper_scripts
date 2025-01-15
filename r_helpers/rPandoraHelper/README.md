
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rPandoraHelper

This is an R package allowing easy conversion of Pandora_IDs to any ID
of higher hierarchical level. No queries to Pandora take place, only
simple text manipulation, and hence this package cannot tell you if the
ID exists.

## Installation

You can install the latest version of rPandoraHelper from a local clone
`helper_scripts` directory by following the steps below:

``` bash
## Assumes you are in the root directory of the helper scripts repository.
cd r_helpers/rPandoraHelper
R --vanilla -e 'install.packages(".", repos = NULL, type = "source")'
```

## Example

This is a basic usage example, converting a full sequencing ID including
the Autorun_eager `_ss` suffix into a its respective Site ID and
Individual ID:

``` r
library(rPandoraHelper)

seq_id <- "ABCDEF001_ss.A0101.SG1.1" ## NOTE: The ID includes the '_ss' suffix added by Autorun_eager to ssDNA data.

site_id <- get_site_id(seq_id) ## ABCDEF
individual_id <- get_ind_id(seq_id) ## ABCDEF001
individual_id_ss <- get_ind_id(seq_id, keep_ss_suffix = T) ## ABCDEF001_ss
```
