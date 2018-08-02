-- 
-- additional steps in setting up OpenMapTiles
-- after running the initial import setup functions, and before importing the OSM/OHM PBF
-- to finish prepping, purging, etc. before the OSM/OHM import
-- 

-- 
-- the documented process for setting up OpenMapTiles includes loading a OSM boundaries dataset from CSV
-- see the import-osmborder step
-- however, we do not want this; empty the osm_border_linestring table
-- if we do want to import boundaries, we would do so in the import-osm step
-- 
TRUNCATE TABLE  osm_border_linestring       ;
TRUNCATE TABLE  osm_border_linestring_gen1  ;
TRUNCATE TABLE  osm_border_linestring_gen10 ;
TRUNCATE TABLE  osm_border_linestring_gen2  ;
TRUNCATE TABLE  osm_border_linestring_gen3  ;
TRUNCATE TABLE  osm_border_linestring_gen4  ;
TRUNCATE TABLE  osm_border_linestring_gen5  ;
TRUNCATE TABLE  osm_border_linestring_gen6  ;
TRUNCATE TABLE  osm_border_linestring_gen7  ;
TRUNCATE TABLE  osm_border_linestring_gen8  ;
TRUNCATE TABLE  osm_border_linestring_gen9  ;

