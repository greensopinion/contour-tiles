PG_PORT_5432_TCP_PORT := 5432
PG_PORT_5432_TCP_ADDR := postgres-osm
PG_USER := contour
PG_PASS := passwd

TIFDIR := /data/tif
DOWNLOADDIR := /data/download

# ----------------------------------------------------------------------------------------------------------------------
#	Main Targets
# ----------------------------------------------------------------------------------------------------------------------

all: /data/mbtiles/hillshade.mbtiles /data/mbtiles/slope.mbtiles /data/mbtiles/contour.mbtiles /data/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles

# ----------------------------------------------------------------------------------------------------------------------
#	Building mbtiles
# ----------------------------------------------------------------------------------------------------------------------

/data/mbtiles/contour.mbtiles: /data/geojson/contour.geojson
	mkdir -p /data/mbtiles
	tippecanoe -f -o /data/mbtiles/contour.mbtiles --no-tile-stats --description "Europe contour lines vector data by singletrail-map.eu" --attribution "©singletrail-map.eu ©OpenStreetMap" /data/geojson/contour.geojson

/data/mbtiles/hillshade.mbtiles: /data/tif/hillshade.tif
	mkdir -p /data/mbtiles
	gdal_translate /data/tif/hillshade.tif /data/mbtiles/hillshade.mbtiles -of MBTILES
	gdaladdo -r nearest /data/mbtiles/hillshade.mbtiles 2 4 8 16

/data/mbtiles/slope.mbtiles: /data/tif/slope.tif
	mkdir -p /data/mbtiles
	gdal_translate /data/tif/slope.tif /data/mbtiles/slope.mbtiles -of MBTILES
	gdaladdo -r nearest /data/mbtiles/slope.mbtiles 2 4 8 16

/data/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles:
	curl https://download.openslopemap.org/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles --output /data/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles

# ----------------------------------------------------------------------------------------------------------------------
#	Building geojson
# ----------------------------------------------------------------------------------------------------------------------

/data/geojson/contour.geojson: /data/geojson/contour20.geojson /data/geojson/contour100.geojson #/data/geojson/glacier_contour20.geojson /data/geojson/glacier_contour100.geojson /data/geojson/rock_contour100.geojson /data/geojson/rock_contour20.geojson
	ogr2ogr -f GeoJSON /data/geojson/contour.geojson /data/geojson/contour20.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/contour100.geojson
	#ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/glacier_contour20.geojson
	#ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/glacier_contour100.geojson
	#ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/rock_contour20.geojson
	#ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/rock_contour100.geojson

/data/geojson/contour20.geojson: /data/shp2pgsql-contour /sql/contour20.sql
        mkdir -p /data/geojson
        ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/contour20.geojson "PG:host=$(PG_PORT_5432_TCP_ADDR) port=$(PG_PORT_5432_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/contour20.sql
        sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/contour20.geojson

/data/geojson/contour100.geojson: /data/shp2pgsql-contour /sql/contour100.sql
        mkdir -p /data/geojson
        ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/contour100.geojson "PG:host=$(PG_PORT_5432_TCP_ADDR) port=$(PG_PORT_5432_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/contour100.sql
        sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/contour100.geojson

/data/geojson/glacier_contour20.geojson: /data/shp2pgsql-contour /sql/glacier_contour20.sql
        mkdir -p /data/geojson
        ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/glacier_contour20.geojson "PG:host=$(PG_PORT_5432_TCP_ADDR) port=$(PG_PORT_5432_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/glacier_contour20.sql
        sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/glacier_contour20.geojson

/data/geojson/glacier_contour100.geojson: /data/shp2pgsql-contour /sql/glacier_contour100.sql
        mkdir -p /data/geojson
        ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/glacier_contour100.geojson "PG:host=$(PG_PORT_5432_TCP_ADDR) port=$(PG_PORT_5432_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/glacier_contour100.sql
        sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/glacier_contour100.geojson

/data/geojson/rock_contour20.geojson: /data/shp2pgsql-contour /sql/rock_contour20.sql
        mkdir -p /data/geojson
        ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/rock_contour20.geojson "PG:host=$(PG_PORT_5432_TCP_ADDR) port=$(PG_PORT_5432_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/rock_contour20.sql
        sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/rock_contour20.geojson

/data/geojson/rock_contour100.geojson: /data/shp2pgsql-contour /sql/rock_contour100.sql
        mkdir -p /data/geojson
        ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/rock_contour100.geojson "PG:host=$(PG_PORT_5432_TCP_ADDR) port=$(PG_PORT_5432_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/rock_contour100.sql
        sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/rock_contour100.geojson

# ----------------------------------------------------------------------------------------------------------------------
# Loading the database
# ----------------------------------------------------------------------------------------------------------------------

/data/shp2pgsql-contour: /data/tif/contour-3785-20m.shp
        PGPASSWORD=$(PG_PASS) psql -h $(PG_PORT_5432_TCP_ADDR) -p $(PG_PORT_5432_TCP_PORT)  -U $(PG_USER) -d gis -c "DROP TABLE IF EXISTS contourlines;"
        /bin/bash -c 'shp2pgsql -s 3857 /data/tif/contour-3785-20m.shp contourlines | PGPASSWORD=$(PG_PASS) psql -v ON_ERROR_STOP=ON -h $(PG_PORT_5432_TCP_ADDR) -p $(PG_PORT_5432_TCP_PORT) -d gis -U $(PG_USER)'
        touch /data/shp2pgsql-contour

# ----------------------------------------------------------------------------------------------------------------------
#	Building tifs
# ----------------------------------------------------------------------------------------------------------------------

/data/tif/contour-3785-20m.shp: /data/tif/contour-3785.tif
	mkdir -p /data/tif
	gdal_contour -a elev -i 20 /data/tif/contour-3785.tif /data/tif/contour-3785-20m.shp

/data/tif/slope.tif: /data/tif/contour-3785.tif
	mkdir -p /data/tif
	gdaldem slope /data/tif/contour-3785.tif /data/tif/slope.tif

/data/tif/hillshade.tif: /data/tif/contour-3785.tif
	mkdir -p /data/tif
	gdaldem hillshade -z 5 /data/tif/contour-3785.tif /data/tif/hillshade.tif

/data/tif/contour-3785.tif: /data/tif/contour-4326.tif
	mkdir -p /data/tif
	gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear /data/tif/contour-4326.tif /data/tif/contour-3785.tif

/data/tif/contour-4326.tif: /data/tif/srtm_34_02.tif \
							/data/tif/srtm_35_01.tif \
							/data/tif/srtm_35_02.tif \
							/data/tif/srtm_35_03.tif \
							/data/tif/srtm_35_04.tif \
							/data/tif/srtm_35_05.tif \
							/data/tif/srtm_36_01.tif \
							/data/tif/srtm_36_02.tif \
							/data/tif/srtm_36_03.tif \
							/data/tif/srtm_36_04.tif \
							/data/tif/srtm_36_05.tif \
 							/data/tif/srtm_37_01.tif \
 							/data/tif/srtm_37_02.tif \
 							/data/tif/srtm_37_03.tif \
 							/data/tif/srtm_37_04.tif \
 							/data/tif/srtm_37_05.tif \
 							/data/tif/srtm_38_01.tif \
 							/data/tif/srtm_38_02.tif \
 							/data/tif/srtm_38_03.tif \
 							/data/tif/srtm_38_04.tif \
 							/data/tif/srtm_38_05.tif \
 							/data/tif/srtm_39_01.tif \
 							/data/tif/srtm_39_02.tif \
 							/data/tif/srtm_39_03.tif \
 							/data/tif/srtm_39_04.tif \
 							/data/tif/srtm_39_05.tif \
 							/data/tif/srtm_40_01.tif \
 							/data/tif/srtm_40_02.tif \
 							/data/tif/srtm_40_03.tif \
 							/data/tif/srtm_40_04.tif \
 							/data/tif/srtm_40_05.tif
	gdal_merge.py -o /data/tif/contour-4326.tif \
					 /data/tif/srtm_34_02.tif \
					 /data/tif/srtm_35_01.tif \
					 /data/tif/srtm_35_02.tif \
					 /data/tif/srtm_35_03.tif \
					 /data/tif/srtm_35_04.tif \
					 /data/tif/srtm_35_05.tif \
					 /data/tif/srtm_36_01.tif \
					 /data/tif/srtm_36_02.tif \
					 /data/tif/srtm_36_03.tif \
					 /data/tif/srtm_36_04.tif \
					 /data/tif/srtm_36_05.tif \
					 /data/tif/srtm_37_01.tif \
					 /data/tif/srtm_37_02.tif \
					 /data/tif/srtm_37_03.tif \
					 /data/tif/srtm_37_04.tif \
					 /data/tif/srtm_37_05.tif \
					 /data/tif/srtm_38_01.tif \
					 /data/tif/srtm_38_02.tif \
					 /data/tif/srtm_38_03.tif \
					 /data/tif/srtm_38_04.tif \
					 /data/tif/srtm_38_05.tif \
					 /data/tif/srtm_39_01.tif \
					 /data/tif/srtm_39_02.tif \
					 /data/tif/srtm_39_03.tif \
					 /data/tif/srtm_39_04.tif \
					 /data/tif/srtm_39_05.tif \
					 /data/tif/srtm_40_01.tif \
					 /data/tif/srtm_40_02.tif \
					 /data/tif/srtm_40_03.tif \
					 /data/tif/srtm_40_04.tif \
					 /data/tif/srtm_40_05.tif

$(TIFDIR)/srtm_%.tif: $(DOWNLOADDIR)/srtm_%.zip
        mkdir -p $(TIFDIR)
        unzip -p $< *.tif > $@


# ----------------------------------------------------------------------------------------------------------------------
#	Downloads
# ----------------------------------------------------------------------------------------------------------------------

$(DOWNLOADDIR)/srtm_%.zip:
        mkdir -p $(DOWNLOADDIR)
        base_name=$(shell basename $@)
        wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/$(shell basename $@) -O $@
        touch $@