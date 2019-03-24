library(sf)

# download geojson for snohomish county precinct polygons and write to shapefile
# yes, tedious.

url <- paste0('http://gismaps.snoco.org/snocogis2/rest/services/districts/districts/MapServer/5/query?',
  'where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&',
  'relationParam=&outFields=PRECINCT%2CPRECINCT_N&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&',
  'returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&',
  'returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=geojson')

#http://gismaps.snoco.org/snocogis2/rest/services/districts/districts/MapServer/5/query?where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=PRECINCT%2CPRECINCT_N&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=geojson

if (dir.exists('/opt/data/Shapefiles/wa-voting-precincts/snohomish-2018')) {
  unlink('/opt/data/Shapefiles/wa-voting-precincts/snohomish-2018', recursive=TRUE)
}
  
dir.create('/opt/data/Shapefiles/wa-voting-precincts/snohomish-2018')
read_sf(url) %>% st_write('/opt/data/Shapefiles/wa-voting-precincts/snohomish-2018/Precincts.shp')
