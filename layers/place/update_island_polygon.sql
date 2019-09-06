-- OMT had these, which force island polygons back to point, which loses their geometry!
-- CREATE OR REPLACE FUNCTION update_osm_island_polygon()
-- CREATE OR REPLACE FUNCTION place_island_polygon.flag()
-- CREATE OR REPLACE FUNCTION place_island_polygon.refresh()

-- so we went back and deleted these, then removed them from this file
-- DROP TRIGGER IF EXISTS trigger_flag ON osm_island_polygon;
-- DROP TRIGGER IF EXISTS trigger_flag ON backup.osm_island_polygon;
-- DROP TRIGGER IF EXISTS trigger_refresh ON place_island_polygon.updates;
-- DROP FUNCTION IF EXISTS update_osm_island_polygon();
-- DROP FUNCTION IF EXISTS place_island_polygon.refresh();
-- DROP FUNCTION IF EXISTS place_island_polygon.flag();

-- we do want to expose islands to the tile service, though
-- see water.sql where we integrate these into the water layer, so match the water fields here
CREATE OR REPLACE VIEW islands_for_tiles AS (
    SELECT osm_id, geometry, 'island'::text AS class, name, start_date, end_date
    FROM osm_island_polygon
);
