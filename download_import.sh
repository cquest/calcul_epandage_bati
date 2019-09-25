# Limites administratives (OpenStreetMap)
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20190101-shp.zip
ogr2ogr -f postgresql PG:dbname=$USER -nln communes -nlt geometry -t_srs EPSG:2154 /vsizip/communes-20190101-shp.zip
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/departements-20190101-shp.zip
ogr2ogr -f postgresql PG:dbname=$USER -nln departements -nlt geometry -t_srs EPSG:2154 /vsizip/departements-20190101-shp.zip

# RPG 2017
wget -nc http://data.cquest.org/registre_parcellaire_graphique/2017/RPG_2-0_SHP_LAMB93_FR-2017-PARCELLES.zip
ogr2ogr -f postgresql PG:dbname=$USER -nln rpg -nlt geometry -a_srs EPSG:2154 -t_srs EPSG:2154 /vsizip/RPG_2-0_SHP_LAMB93_FR-2017-PARCELLES.zip

# Bâtiment du PCI vecteur
cd bati
for DEP in $(seq -w 01 95) 2A 2B
do
  wget -nc https://cadastre.data.gouv.fr/data/etalab-cadastre/latest/geojson/departements/$DEP/cadastre-$DEP-batiments.json.gz
done
find . -name *batiments.json.gz | parallel -j 6 ogr2ogr -f postgresql PG:dbname=$USER -nln bati -nlt geometry -t_srs EPSG:2154 /vsigzip/{}

