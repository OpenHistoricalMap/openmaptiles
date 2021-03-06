-- OHM note: these include NaturalEarth content which is not Historical
-- the question is pending, whether incluing non-OHM data is appropriate - GDA 2018-July

CREATE OR REPLACE FUNCTION landcover_class(landuse VARCHAR, "natural" VARCHAR, leisure VARCHAR, wetland VARCHAR) RETURNS TEXT AS $$
    SELECT CASE
        WHEN "natural" IN ('land') THEN 'land'
        WHEN landuse IN ('farmland', 'farm', 'orchard', 'vineyard', 'plant_nursery') THEN 'farmland'
        WHEN "natural" IN ('glacier', 'ice_shelf') THEN 'ice'
        WHEN "natural"='wood' OR landuse IN ('forest') THEN 'wood'
        WHEN "natural" IN ('bare_rock', 'scree') THEN 'rock'
        WHEN "natural"='grassland'
            OR landuse IN ('grass', 'meadow', 'allotments', 'grassland',
                'park', 'village_green', 'recreation_ground')
            OR leisure IN ('park', 'garden')
            THEN 'grass'
        WHEN "natural"='wetland' OR wetland IN ('bog', 'swamp', 'wet_meadow', 'marsh', 'reedbed', 'saltern', 'tidalflat', 'saltmarsh', 'mangrove') THEN 'wetland'
        WHEN "natural"IN ('beach', 'sand') THEN 'sand'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE;

-- etldoc: ne_110m_glaciated_areas ->  landcover_z0
CREATE OR REPLACE VIEW landcover_z0 AS (
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'glacier'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland, ''::text AS start_date, ''::text AS end_date
    FROM ne_110m_glaciated_areas
);

CREATE OR REPLACE VIEW landcover_z2 AS (
    -- etldoc: ne_50m_glaciated_areas ->  landcover_z2
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'glacier'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland, ''::text AS start_date, ''::text AS end_date
    FROM ne_50m_glaciated_areas
    UNION ALL
    -- etldoc: ne_50m_antarctic_ice_shelves_polys ->  landcover_z2
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'ice_shelf'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland, ''::text AS start_date, ''::text AS end_date
    FROM ne_50m_antarctic_ice_shelves_polys
);

CREATE OR REPLACE VIEW landcover_z5 AS (
    -- etldoc: osm_landcover_polygon_gen7 ->  landcover_z7
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen7
);

CREATE OR REPLACE VIEW landcover_z7 AS (
    -- etldoc: osm_landcover_polygon_gen7 ->  landcover_z7
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen7
);

CREATE OR REPLACE VIEW landcover_z8 AS (
    -- etldoc: osm_landcover_polygon_gen6 ->  landcover_z8
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen6
);

CREATE OR REPLACE VIEW landcover_z9 AS (
    -- etldoc: osm_landcover_polygon_gen5 ->  landcover_z9
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen5
);

CREATE OR REPLACE VIEW landcover_z10 AS (
    -- etldoc: osm_landcover_polygon_gen4 ->  landcover_z10
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen4
);

CREATE OR REPLACE VIEW landcover_z11 AS (
    -- etldoc: osm_landcover_polygon_gen3 ->  landcover_z11
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen3
);

CREATE OR REPLACE VIEW landcover_z12 AS (
    -- etldoc: osm_landcover_polygon_gen2 ->  landcover_z12
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen2
);

CREATE OR REPLACE VIEW landcover_z13 AS (
    -- etldoc: osm_landcover_polygon_gen1 ->  landcover_z13
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon_gen1
);

CREATE OR REPLACE VIEW landcover_z14 AS (
    -- etldoc: osm_landcover_polygon ->  landcover_z14
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland, start_date, end_date
    FROM osm_landcover_polygon
);

-- etldoc: layer_landcover[shape=record fillcolor=lightpink, style="rounded, filled", label="layer_landcover | <z0_1> z0-z1 | <z2_4> z2-z4 | <z5_6> z5-z6 |<z7> z7 |<z8> z8 |<z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_landcover(bbox geometry, zoom_level int)
RETURNS TABLE(osm_id bigint, geometry geometry, class text, subclass text, start_date text, end_date text) AS $$
    SELECT osm_id, geometry,
        landcover_class(landuse, "natural", leisure, wetland) AS class,
        COALESCE(
            NULLIF("natural", ''), NULLIF(landuse, ''),
            NULLIF(leisure, ''), NULLIF(wetland, '')
        ) AS subclass,
        start_date, end_date
        FROM (
        -- etldoc:  landcover_z0 -> layer_landcover:z0_1
        SELECT * FROM landcover_z0
        WHERE zoom_level BETWEEN 0 AND 1 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z2 -> layer_landcover:z2_4
        SELECT * FROM landcover_z2
        WHERE zoom_level BETWEEN 2 AND 4 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z5 -> layer_landcover:z5_6
        SELECT * FROM landcover_z5
        WHERE zoom_level BETWEEN 5 AND 6 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z7 -> layer_landcover:z7
        SELECT *
        FROM landcover_z7 WHERE zoom_level = 7 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z8 -> layer_landcover:z8
        SELECT *
        FROM landcover_z8 WHERE zoom_level = 8 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z9 -> layer_landcover:z9
        SELECT *
        FROM landcover_z9 WHERE zoom_level = 9 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z10 -> layer_landcover:z10
        SELECT *
        FROM landcover_z10 WHERE zoom_level = 10 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z11 -> layer_landcover:z11
        SELECT *
        FROM landcover_z11 WHERE zoom_level = 11 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z12 -> layer_landcover:z12
        SELECT *
        FROM landcover_z12 WHERE zoom_level = 12 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z13 -> layer_landcover:z13
        SELECT *
        FROM landcover_z13 WHERE zoom_level = 13 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z14 -> layer_landcover:z14_
        SELECT *
        FROM landcover_z14 WHERE zoom_level >= 14 AND geometry && bbox
        UNION ALL
        SELECT
            osm_id, geometry,
            'land' AS landuse, 'land' as "natural",
            NULL::varchar AS leisure, NULL::varchar AS wetland,
            start_date, end_date
        FROM islands_for_tiles WHERE geometry && bbox
    ) AS zoom_levels;
$$ LANGUAGE SQL IMMUTABLE;
