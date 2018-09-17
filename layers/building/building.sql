-- OHM note: the OSM tables osm_building_relation osm_building_associatedstreet osm_building_street osm_building_polygon
-- do not contain any name field, so don't bother
-- but it does have a "building" field, so we can sometimes describe what the building is used for - GDA 2018 July



-- etldoc: layer_building[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_building | <z13> z13 | <z14_> z14+ " ] ;

CREATE OR REPLACE FUNCTION as_numeric(text) RETURNS NUMERIC AS $$
 -- Inspired by http://stackoverflow.com/questions/16195986/isnumeric-with-postgresql/16206123#16206123
DECLARE test NUMERIC;
BEGIN
     test = $1::NUMERIC;
     RETURN test;
EXCEPTION WHEN others THEN
     RETURN -1;
END;
$$ STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE INDEX IF NOT EXISTS osm_building_relation_building_idx ON osm_building_relation(building);
--CREATE INDEX IF NOT EXISTS osm_building_associatedstreet_role_idx ON osm_building_associatedstreet(role);
--CREATE INDEX IF NOT EXISTS osm_building_street_role_idx ON osm_building_street(role);

CREATE OR REPLACE VIEW osm_all_buildings AS (
         -- etldoc: osm_building_relation -> layer_building:z14_
         -- Buildings built from relations
         SELECT member AS osm_id, geometry,
                name, building,
                height, min_height,
                start_date, end_date
         FROM osm_building_relation
         WHERE building = ''
         UNION ALL

         -- etldoc: osm_building_associatedstreet -> layer_building:z14_
         -- Buildings in associatedstreet relations
         SELECT member AS osm_id, geometry,
                name, building,
                height, min_height,
                start_date, end_date
         FROM osm_building_associatedstreet
         WHERE role = 'house'
         UNION ALL
         -- etldoc: osm_building_street -> layer_building:z14_
         -- Buildings in street relations
         SELECT member AS osm_id, geometry,
                name, building,
                height, min_height,
                start_date, end_date
         FROM osm_building_street
         WHERE role = 'house'
         UNION ALL

         -- etldoc: osm_building_multipolygon -> layer_building:z14_
         -- Buildings that are inner/outer
         SELECT osm_id,geometry,
                name, building,
                height, min_height,
                start_date, end_date
         FROM osm_building_polygon obp
         WHERE EXISTS (SELECT 1 FROM osm_building_multipolygon obm WHERE obp.osm_id = obm.osm_id)
         UNION ALL
         -- etldoc: osm_building_polygon -> layer_building:z14_
         -- Standalone buildings
         SELECT osm_id,geometry,
                name, building,
                height, min_height,
                start_date, end_date
         FROM osm_building_polygon
         WHERE osm_id >= 0
);

CREATE OR REPLACE FUNCTION layer_building(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, osm_id bigint, height varchar, min_height varchar, name varchar, building text, start_date text, end_date text) AS $$
    SELECT geometry,
        osm_id,
        height,
        min_height,
        name,
        CASE WHEN building = 'yes' THEN '' ELSE building END,
        start_date,
        end_date
    FROM (
        -- etldoc: osm_building_polygon_gen1 -> layer_building:z13
        SELECT
            osm_id, geometry,
            height, min_height,
            name, building, start_date, end_date
        FROM osm_building_polygon_gen1
        WHERE zoom_level = 13 AND geometry && bbox
        UNION ALL
        -- etldoc: osm_building_polygon -> layer_building:z14_
        SELECT DISTINCT ON (osm_id)
           osm_id, geometry,
           height, min_height,
           name, building, start_date, end_date
        FROM osm_all_buildings
        WHERE zoom_level >= 14 AND geometry && bbox
    ) AS zoom_levels
    ORDER BY height ASC, ST_YMin(geometry) DESC;
$$ LANGUAGE SQL IMMUTABLE;

-- not handled: where a building outline covers building parts
