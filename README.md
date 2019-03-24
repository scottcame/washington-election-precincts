### Washington State Elections Precincts

This repository contains an R script that assembles a set of polygons for election precincts in Washington to correspond with the actual
precincts for each election in the state.

The Washington Secretary of State maintains a [shapefile](https://www.sos.wa.gov/elections/research/precinct-shapefiles.aspx) but it is
generally updated with changes from the 39 counties sometime after the elections in which those changes take effect. The goal of this
repository is to collect precinct polygon data from the counties directly to enable contemporaneous analysis of each election.

The target set of precincts are those reflected in official election results, as curated by the [Open Elections Project](http://www.openelections.net/) whose
Washington State results data are available on [github](https://github.com/openelections/openelections-data-wa).