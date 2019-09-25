# Vue pour récupérer les parcelles du RPG dont le centroid se trouve dans une commune

psql -c
"CREATE VIEW rpg_communes AS
 SELECT c.insee,
    p.ogc_fid,
    p.id_parcel,
    p.surf_parc,
    p.code_cultu,
    p.code_group,
    p.culture_d1,
    p.culture_d2,
    p.wkb_geometry
   FROM communes c
     JOIN rpg p ON p.wkb_geometry && c.wkb_geometry AND st_intersects(c.wkb_geometry, st_centroid(p.wkb_geometry));
"

# calcul des buffers
for DIST in 150 50 20 10
do
  psql -c "create table rpg$DIST (id integer, insee text, geom geometry);"
  for D in $(seq -w 0 9)
  do
    echo $D $DIST
    psql -c "select insee from communes where insee like '$D%' order by insee" -tA | parallel sh rpg_buffer-sql.sh $DIST {} > /dev/null
  done
  psql -c "create index on rpg$DIST using gist (wkb_geometry);" &
  psql -c "
  create index on rpg$DIST using spgist (insee);
  CREATE MATERIALIZED VIEW stats$DIST
    SELECT insee, sum(st_area(geom)) / 10000::double precision AS s10
    FROM rpg$DIST
    GROUP BY insee;"  
done

# export CSV par départements et communes
psql -c "copy (SELECT left(r.insee, 2) AS dep,
    d.nom,
    floor(st_area(d.wkb_geometry) / 10000) AS surf_dep,
    floor(sum(r.total)) AS total,
    floor(sum(stats150.s150)) AS s150,
    floor(sum(stats50.s50)) AS s50,
    floor(sum(stats20.s20)) AS s20,
    floor(sum(stats10.s10)) AS s10
   FROM stats r
     LEFT JOIN departements d ON d.code_insee::text = left(r.insee, 2)
     JOIN stats150 USING (insee)
     JOIN stats50 USING (insee)
     JOIN stats20 USING (insee)
     JOIN stats10 USING (insee)
  GROUP BY 1,2, d.wkb_geometry)
  to '/tmp/epandage_par_dep.csv' WITH (format csv, header true)"

psql -c "copy (SELECT r.insee,
    c.nom,
    floor(st_area(c.wkb_geometry) / 10000) AS surf_dep,
    floor(sum(r.total)) AS total,
    floor(sum(stats150.s150)) AS s150,
    floor(sum(stats50.s50)) AS s50,
    floor(sum(stats20.s20)) AS s20,
    floor(sum(stats10.s10)) AS s10
   FROM stats r
     NATURAL JOIN stats150
     NATURAL JOIN stats50
     NATURAL JOIN stats20
     NATURAL JOIN stats10
     LEFT JOIN communes_2019 c ON c.insee = r.insee
  GROUP BY 1,2, c.wkb_geometry)
  to '/tmp/epandage_par_commune.csv' WITH (format csv, header true)"

mv /tmp/epandage*.csv ./
