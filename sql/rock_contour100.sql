select
    'rock' as type,
    '100m' as distance,
    contourlines.elev,
    ST_Intersection(contourlines.geom, planet_osm_polygon.way) as geom
from contourlines, planet_osm_polygon
where planet_osm_polygon.natural in ('bare_rock', 'scree')
  and mod(cast(contourlines.elev as integer), 100) = 0
  and ST_Intersects(planet_osm_polygon.way, contourlines.geom)