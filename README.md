# Scripts de calculs des zones cultivées autour des bâtiments

Sources de données:
- Registre Parcellaire Graphique (ASP)
- Plan Cadastre Informatisé vectoriel (DGFiP)

![](https://raw.githubusercontent.com/cquest/calcul_epandage_bati/master/images/zones_150m.png "En rouge: les surfaces cultivées à moins de 150m d'un bâtiment")

## Outils utilisés

- Postgresql + postgis

## Utilisation des scripts

- download_import.sh : télécharge les données nécessaires et les importe dans une base postgres/postgis locale
- calcul.sh : effectue le calcul des zones impactées et exporte le résultat agrégé par département et commune dans deux fichiers CSV

## Résultats

- epandage_par_commune.csv
- epandage_par_dep.csv

Colonnes:
- dep/insee: code INSEE du département ou de la commune
- nom: nom du département ou de la commune
- surf: surface totale en ha du département ou de la commune
- total: surface totale des parcelles présentes dans le RPG sur le département ou la commune
- s150: total de la surface cultivées en ha correspondant à une distance de 150m autour des bâtiments
- s50: idem pour 50m
- s20: idem pour 20m
- s10: idem pour 10m
