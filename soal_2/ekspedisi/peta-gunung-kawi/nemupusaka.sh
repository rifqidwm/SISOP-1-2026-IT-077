#!/bin/bash
baris1=$(head -1 titik-penting.txt)
baris2=$(head -2 titik-penting.txt | tail -1)
baris3=$(head -3 titik-penting.txt | tail -1)
baris4=$(head -4 titik-penting.txt | tail -1)

lat1=$(echo "$baris1" | cut -d',' -f3)
lon1=$(echo "$baris1" | cut -d',' -f4)

lat2=$(echo "$baris2" | cut -d',' -f3)
lon2=$(echo "$baris2" | cut -d',' -f4)

lat3=$(echo "$baris3" | cut -d',' -f3)
lon3=$(echo "$baris3" | cut -d',' -f4)

lat4=$(echo "$baris4" | cut -d',' -f3)
lon4=$(echo "$baris4" | cut -d',' -f4)

lat_tengah=$(echo "scale=6; ($lat1 + $lat3) / 2" | bc)
lon_tengah=$(echo "scale=6; ($lon1 + $lon3) / 2" | bc)

echo "$lat_tengah,$lon_tengah" > posisipusaka.txt
echo "Koordinat pusat:"
cat posisipusaka.txt
