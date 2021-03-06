## OpenMapTiles [![Build Status](https://travis-ci.org/openmaptiles/openmaptiles.svg?branch=master)](https://travis-ci.org/openmaptiles/openmaptiles)

OpenMapTiles is an extensible and open vector tile schema for a OpenStreetMap basemap. It is used to generate vector tiles for [openmaptiles.org](http://openmaptiles.org/) and [openmaptiles.com](http://openmaptiles.com/).

We encourage you to collaborate, reuse and adapt existing layers and add your own layers or use our approach for your own vector tile project. The repository is built on top of the [openmaptiles/tools](https://github.com/openmaptiles/openmaptiles-tools) to simplify vector tile creation.

- :link: Docs http://openmaptiles.org/docs
- :link: Schema: http://openmaptiles.org/schema
- :link: Production package: http://openmaptiles.com/

## Styles

You can start from several GL styles supporting the OpenMapTiles vector schema.

:link: [Learn how to create Mapbox GL styles with Maputnik and OpenMapTiles](http://openmaptiles.org/docs/style/maputnik/).


- [OSM Bright](https://github.com/openmaptiles/osm-bright-gl-style)
- [Positron](https://github.com/openmaptiles/positron-gl-style)
- [Dark Matter](https://github.com/openmaptiles/dark-matter-gl-style)
- [Klokantech Basic](https://github.com/openmaptiles/klokantech-basic-gl-style)
- [Klokantech 3D](https://github.com/openmaptiles/klokantech-3d-gl-style)
- [Fiord Color](https://github.com/openmaptiles/fiord-color-gl-style)
- [Toner](https://github.com/openmaptiles/toner-gl-style)

We also ported over our favorite old raster styles (TM2).

:link: [Learn how to create TM2 styles with Mapbox Studio Classic and OpenMapTiles](http://openmaptiles.org/docs/style/mapbox-studio-classic/).

- [Light](https://github.com/openmaptiles/mapbox-studio-light.tm2/)
- [Dark](https://github.com/openmaptiles/mapbox-studio-dark.tm2/)
- [OSM Bright](https://github.com/openmaptiles/mapbox-studio-osm-bright.tm2/)
- [Pencil](https://github.com/openmaptiles/mapbox-studio-pencil.tm2/)
- [Woodcut](https://github.com/openmaptiles/mapbox-studio-woodcut.tm2/)
- [Pirates](https://github.com/openmaptiles/mapbox-studio-pirates.tm2/)
- [Wheatpaste](https://github.com/openmaptiles/mapbox-studio-wheatpaste.tm2/)

## Schema

OpenMapTiles consists out of a collection of documented and self contained layers you can modify and adapt.
Together the layers make up the OpenMapTiles tileset.

:link: [Study the vector tile schema](http://openmaptiles.org/schema)

- [aeroway](https://openmaptiles.org/schema/#aeroway)
- [boundary](https://openmaptiles.org/schema/#boundary)
- [building](https://openmaptiles.org/schema/#building)
- [housenumber](https://openmaptiles.org/schema/#housenumber)
- [landcover](https://openmaptiles.org/schema/#landcover)
- [landuse](https://openmaptiles.org/schema/#landuse)
- [mountain_peak](https://openmaptiles.org/schema/#mountain_peak)
- [park](https://openmaptiles.org/schema/#park)
- [place](https://openmaptiles.org/schema/#place)
- [poi](https://openmaptiles.org/schema/#poi)
- [transportation](https://openmaptiles.org/schema/#transportation)
- [transportation_name](https://openmaptiles.org/schema/#transportation_name)
- [water](https://openmaptiles.org/schema/#water)
- [water_name](https://openmaptiles.org/schema/#water_name)
- [waterway](https://openmaptiles.org/schema/#waterway)

## Develop

To work on OpenMapTiles you need Docker and Python.

- Install [Docker](https://docs.docker.com/engine/installation/). Minimum version is 1.12.3+.
- Install [Docker Compose](https://docs.docker.com/compose/install/). Minimum version is 1.7.1+.
- Install [OpenMapTiles tools](https://github.com/openmaptiles/openmaptiles-tools) with `pip install openmaptiles-tools`

### Build

Build the tileset.

```bash
git clone git@github.com:openmaptiles/openmaptiles.git
cd openmaptiles

# Build the imposm mapping, the tm2source project and collect all SQL scripts
make
```

### Prepare the Database

Now start up the database container.

```bash
docker-compose up -d postgres
```

Import external data from [OpenStreetMapData](http://openstreetmapdata.com/), [Natural Earth](http://www.naturalearthdata.com/) and  [OpenStreetMap Lake Labels](https://github.com/lukasmartinelli/osm-lakelines).

```bash
docker-compose run --rm import-water
docker-compose run --rm import-natural-earth
docker-compose run --rm import-lakelines
```

Run our customized OHM border system, extracting OHM borders to CSV then importing that CSV. The "makecsv" step takes 25 minutes, but the "import" step takes a few seconds.

```bash
docker-compose run --rm makecsv-osmborder
docker-compose run --rm import-osmborder
```

### Additional Preprocessing

The SQL file `build/ohm_preprocessing.sql` has some additional preprocessing steps specific to OpenHistoricalMap, e.g. emptying some data, creating custom fields, ...

```bash
psql -h 127.0.0.1 -U openmaptiles openmaptiles -f build/ohm_preprocessing.sql
```

### Import OHM PBF

Download the OpenHistoricalMap planet file, and store the PBF file in the `./data` directory. Then [Import OpenStreetMap data](https://github.com/openmaptiles/import-osm) with the mapping rules from `build/mapping.yaml` (which has been created by `make`).

```bash
cd data
(instructions TBD)

docker-compose run --rm import-osm

make clean && make

docker-compose run --rm import-sql
```


### Additional Postprocessing

The SQL file `build/ohm_postprocessing.sql` has some additional postprocessing steps specific to OpenHistoricalMap, e.g. emptying some data, creating custom fields, ...

```bash
psql -U openmaptiles openmaptiles -f build/ohm_postprocessing.sql
```


### Vector Tile Rendering with Tessera

```bash
npm install tessera @mapbox/tilelive-vector tilelive-tmsource tilelive-xray
node_modules/.bin/tessera tmsource://./build/openmaptiles.tm2source
```

## Updating OHM

A service wrapper runs `docker-compose run --rm update-osm` constantly, 24x7. As such, there should be no additional intervention necessary. See the *openhistoricaltiles* repository for more details on this service wrapper.


## License

All code in this repository is under the [BSD license](./LICENSE.md) and the cartography decisions encoded in the schema and SQL are licensed under [CC-BY](./LICENSE.md).

Products or services using maps derived from OpenMapTiles schema need to visibly credit "OpenMapTiles.org" or reference "OpenMapTiles" with a link to http://openmaptiles.org/. Exceptions to attribution requirement can be granted on request.

For a browsable electronic map based on OpenMapTiles and OpenStreetMap data, the
credit should appear in the corner of the map. For example:

[© OpenMapTiles](http://openmaptiles.org/) [© OpenStreetMap contributors](http://www.openstreetmap.org/copyright)

For printed and static maps a similar attribution should be made in a textual
description near the image, in the same fashion as if you cite a photograph.
