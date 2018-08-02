-- 
-- additional steps in setting up OpenMapTiles
-- after running the import-osm and import-sql steps
-- for additional processing not readily worked into those layers/*/*.sql scripts
-- 

-- this is in layers/poi/poi_stop_agg.sql but apparently doesn't get run
ALTER TABLE osm_poi_point ADD COLUMN IF NOT EXISTS agg_stop INTEGER DEFAULT NULL;
SELECT update_osm_poi_point_agg();

