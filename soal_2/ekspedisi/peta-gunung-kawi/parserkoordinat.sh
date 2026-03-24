#!/bin/bash
ids=$(grep '"id"' gsxtrack.json | grep "node_" | sed 's/.*"id": "\(.*\)".*/\1/')
names=$(grep '"site_name"' gsxtrack.json | sed 's/.*"site_name": "\(.*\)".*/\1/')
lats=$(grep '"latitude"' gsxtrack.json | sed 's/.*"latitude": \(.*\),/\1/')
lons=$(grep '"longitude"' gsxtrack.json | sed 's/.*"longitude": \(.*\),/\1/')
paste -d',' <(echo "$ids") <(echo "$names") <(echo "$lats") <(echo "$lons") > titik-penting.txt

cat titik-penting.txt
