# Assembles a set of polygon features for Washington State voting precincts from the Washington Secretary of State and county auditors
# Goal is to match precincts with the Open Elections results file for the 2018 General Election and as many special, primary, and general
# elections after that as possible.

# In Washington, the 39 county auditors (who are the local election officials) maintain data (usually in shapefile format) and submit precinct
# changes to the Secretary of State.  But there is usually some delay in having these changes reflected in the SoS shapefile. Thus
# we delta the SoS file against the Open Elections results and contact the counties for any updates.

library(tidyverse)
library(sf)
library(stringr)
library(readxl)
library(units)

# Downloaded from Washington Secretary of State elections division at https://www.sos.wa.gov/elections/research/precinct-shapefiles.aspx
precinctShp2018 <- read_sf('/opt/data/Shapefiles/wa-voting-precincts/statewide-2017/Statewide_Prec_2017.shp') %>%
  filter(!(COUNTY %in% c('King', 'Pierce', 'Snohomish', 'Thurston', 'Kitsap', 'Chelan', 'Yakima', 'Cowlitz', 'Clark')))

precinctShp2018 <- precinctShp2018 %>%
  select(COUNTY, COUNTYCODE, PRECCODE, PRECNAME) %>%
  rbind(
    # Downloaded via ArcGIS at https://gis-kingcounty.opendata.arcgis.com/datasets/voting-districts-of-king-county--votdst-area
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/king-2018/votdst.shp') %>%
      mutate(COUNTY='King', COUNTYCODE='KI') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=votdst, PRECNAME=NAME)
  ) %>%
  rbind(
    # Downloaded via ArcGIS at http://gisdata-piercecowa.opendata.arcgis.com/datasets/election-precincts
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/pierce-2018/Election_Precincts.shp') %>%
      mutate(COUNTY='Pierce', COUNTYCODE='PI') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=PRECINCT, PRECNAME=NAME)
  )  %>%
  rbind(
    # Downloaded at http://www.mediafire.com/file/xccjad2wndtj663/ElectionDistrict.zip/file
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/benton-2018/ElectionDistrict.shp') %>%
      mutate(COUNTY='Benton', COUNTYCODE='BE') %>%
      filter(DistrictNa=='6151') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=DistrictNa, PRECNAME=Jurisdicti)
  )  %>%
  rbind(
    # Downloaded via ArcGIS REST services; see SnohomishMapServerToShp.R
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/snohomish-2018/Precincts.shp') %>%
      mutate(COUNTY='Snohomish', COUNTYCODE='SN') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=PRECINCT, PRECNAME=PRECINCT_N)
  )  %>%
  rbind(
    # Downloaded from ArcGIS at http://gisdata-thurston.opendata.arcgis.com/datasets/dea9941fd7c241abaddcd08af1e32e0f_0
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/thurston-2018/Thurston_Voters_Precincts.shp') %>%
      mutate(COUNTY='Thurston', COUNTYCODE='TH') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=PrecinctNu, PRECNAME=Name)
  )  %>%
  rbind(
    # Downloaded from ftp://kcftp2.co.kitsap.wa.us/gis/datacd/arcview/layers/districts/precincts.zip
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/kitsap-2018/precincts.shp') %>%
      mutate(COUNTY='Kitsap', COUNTYCODE='KP') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=DISTRICT, PRECNAME=DESCR)
  )  %>%
  rbind(
    # Obtained by request from Chelan County Auditor
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/chelan-2018/Export_Output_3.shp') %>%
      mutate(COUNTY='Chelan', COUNTYCODE='CH') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=PRECINCT) %>% mutate(PRECNAME=PRECCODE)
  )  %>%
  rbind(
    # Downloaded from ArcGIS at http://gis-yakimacounty.opendata.arcgis.com/datasets/precincts
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/yakima-2018/Precincts.shp') %>%
      mutate(COUNTY='Yakima', COUNTYCODE='YA') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=CODE) %>% mutate(PRECNAME=PRECCODE)
  )  %>%
  rbind(
    # Obtained by request from Cowlitz County Auditor
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/cowlitz-2018/Export_Output.shp') %>%
      mutate(COUNTY='Cowlitz', COUNTYCODE='CZ') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      mutate(Precinct_N=case_when(grepl(x=Precinct_1, pattern='^Yale') ~ 74.0, TRUE ~ Precinct_N)) %>%
      mutate(PRECCODE=as.character(as.integer(Precinct_N))) %>%
      rename(PRECNAME=Precinct_1) %>%
      select(COUNTY, COUNTYCODE, PRECCODE, PRECNAME)
  )  %>%
  rbind(
    # Obtained from Washington SoS Elections Division (provided to them by Clark County Auditor)
    read_sf('/opt/data/Shapefiles/wa-voting-precincts/clark-2018/Clark2018/Precinct.shp') %>%
      mutate(COUNTY='Clark', COUNTYCODE='CR') %>%
      st_transform(st_crs(precinctShp2018)$proj4string) %>%
      select(COUNTY, COUNTYCODE, PRECCODE=PRECINCT) %>% mutate(PRECNAME=PRECCODE)
  )

# Per Whitman County Auditor 12/7/2018
whitmanCountyEdits <- tribble(
  ~PRECNAME, ~newCode,
  'Tekoa City', '31',
  'Oakesdale City', '32',
  'Farmington City', '33',
  'Garfield City', '34',
  'Colton City', '35',
  'Uniontown City', '36',
  'Albion City', '37',
  'LaCrosse City', '42',
  'Endicott City', '43',
  'Lamont City', '44',
  'St. John City', '45',
  'Malden City', '46',
  'Rosalia City', '47'
)

precinctShp2018 <- precinctShp2018 %>%
  left_join(whitmanCountyEdits,  by='PRECNAME') %>%
  mutate(PRECCODE=case_when(is.na(newCode) ~ PRECCODE, TRUE ~ newCode)) %>% select(-newCode)

rm(whitmanCountyEdits)

results2018 <- read_csv('https://raw.githubusercontent.com/openelections/openelections-data-wa/master/2018/20181106__wa__general__precinct.csv', col_types=cols(.default=col_character())) %>%
  mutate(votes=as.integer(votes)) %>%
  mutate(
    precinct=case_when(county=='King' ~ str_pad(precinct, 4, 'left', '0'), TRUE ~ precinct),
    precinct=case_when(county=='Pierce' ~ str_pad(precinct, 5, 'left', '0'), TRUE ~ precinct),
    precinct=case_when(county=='Thurston' ~ str_pad(precinct, 3, 'left', '0'), TRUE ~ precinct),
    precinct=case_when(county=='Kitsap' ~ gsub(x=precinct, pattern='1[0]+([0-9]+)', replacement='\\1'), TRUE ~ precinct),
    precinct=case_when(county=='Skagit' & precinct=='901' ~ '855', TRUE ~ precinct),
    # per Whatcom, new precinct resulted from an annexation, new shp not available until 2019.  most of 271 came from 159 so we will aggregate there.
    precinct=case_when(county=='Whatcom' & precinct=='271' ~ '159', TRUE ~ precinct),
  ) %>%
  group_by(county, precinct, office, district, party, candidate) %>%
  summarize(votes=sum(votes)) %>% ungroup() %>%
  filter(!(county=='Yakima' & precinct=='1')) # weird no-vote Yakima precinct...

resultsNoShp <- results2018 %>% anti_join(precinctShp2018, by=c('county'='COUNTY', 'precinct'='PRECCODE'))
shpNoResult <- precinctShp2018 %>% st_set_geometry(NULL) %>% anti_join(results2018, by=c('COUNTY'='county', 'PRECCODE'='precinct'))

precinctDistrict <- results2018 %>%
  filter(office=='U.S. Representative') %>% select(county, precinct, CongressionalDistrict=district) %>% distinct() %>%
  inner_join(precinctShp2018 %>% st_set_geometry(NULL) %>% select(CountyCode=COUNTYCODE, County=COUNTY) %>% distinct(), by=c('county'='County')) %>%
  inner_join(
    results2018 %>%
      filter(grepl(x=office, pattern='State Representative')) %>% select(county, precinct, LegislativeDistrict=district) %>% distinct(),
    by=c('county','precinct')
  ) %>% mutate_at(vars(ends_with('District')), as.integer)

unassignedPrecinctsFromShp <- precinctShp2018 %>% anti_join(precinctDistrict, by=c('COUNTYCODE'='CountyCode', 'PRECCODE'='precinct'))

# downloaded manually from https://www.census.gov/geo/maps-data/data/cbf/cbf_cds.html
unassignedPrecinctsCd <- read_sf('/opt/data/Shapefiles/cb_2017_us_cd115_500k/cb_2017_us_cd115_500k.shp') %>%
  filter(STATEFP=='53') %>%
  st_transform(st_crs(unassignedPrecinctsFromShp)$proj4string) %>%
  st_intersection(unassignedPrecinctsFromShp) %>%
  mutate(Area=as.integer(set_units(st_area(.), 'acre'))) %>%
  st_set_geometry(NULL) %>%
  select(county=COUNTY, CountyCode=COUNTYCODE, precinct=PRECCODE, CongressionalDistrict=CD115FP, Area) %>%
  arrange(county, precinct, desc(Area)) %>%
  group_by(county, precinct) %>% filter(row_number()==1) %>% ungroup() %>%
  mutate(CongressionalDistrict=as.integer(CongressionalDistrict)) %>% select(-Area)

# downloaded manually from https://www.census.gov/geo/maps-data/data/cbf/cbf_sld.html
unassignedPrecinctsLd <- read_sf('/opt/data/Shapefiles/cb_2017_53_sldl_500k/cb_2017_53_sldl_500k.shp') %>%
  filter(STATEFP=='53') %>%
  st_transform(st_crs(unassignedPrecinctsFromShp)$proj4string) %>%
  st_intersection(unassignedPrecinctsFromShp) %>%
  mutate(Area=as.integer(set_units(st_area(.), 'acre'))) %>%
  st_set_geometry(NULL) %>%
  select(county=COUNTY, CountyCode=COUNTYCODE, precinct=PRECCODE, LegislativeDistrict=SLDLST, Area) %>%
  arrange(county, precinct, desc(Area)) %>%
  group_by(county, precinct) %>% filter(row_number()==1) %>% ungroup() %>%
  mutate(LegislativeDistrict=as.integer(LegislativeDistrict)) %>% select(-CountyCode, -Area)

unassignedPrecincts <- inner_join(unassignedPrecinctsCd, unassignedPrecinctsLd, by=c('county', 'precinct'))

precinctDistrict <- bind_rows(precinctDistrict, unassignedPrecincts)

precinctShp2018 <- precinctShp2018 %>%
  left_join(precinctDistrict %>% select(-county), by=c('COUNTYCODE'='CountyCode', 'PRECCODE'='precinct'))

rm(unassignedPrecincts, unassignedPrecinctsCd, unassignedPrecinctsLd, unassignedPrecinctsFromShp, precinctDistrict)

precinctShp2018 %>%
  # default geojson projection is longlat WGS84
  st_transform(st_crs("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")) %>%
  write_sf('wa-precincts-2018-general.geojson', delete_dsn=TRUE)

