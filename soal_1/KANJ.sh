BEGIN{
FS = ","
opsi = ARGV[2]
delete ARGV[2]
}

NR > 1 {
	if(opsi == "a") count++
	if(opsi == "b") { gsub(/\r/, "", $4); gerbong[$4] = 1 }
	if(opsi == "c") {
		if($2 > max_usia) {max_usia = $2; nama_tertua = $1 }
 }
	if(opsi == "d") { total_usia += $2; count++ }
	if(opsi == "e") {if ($3 == "Business") business++}
}

END {
	if(opsi == "a") print"Total semua penumpang KANJ adalah " count " orang "
	else if(opsi == "b") print"Total gerbong penumpang KANJ adalah " length(gerbong)
	else if(opsi == "c") print nama_tertua " adalah penumpang kereta tertua dengan usia " max_usia " tahun"
	else if(opsi == "d") print "Rata-rata usia penumpang adalah " int(total_usia/count) " tahun"
	else if(opsi == "e") print "Total penumpang business class ada " business "orang"
else{ 
	print "Soal tidak dikenali, Gunakan a,b,c,d,e."
	print "Contoh pemakaian: awk -f file.sh data.csv a"}
}
