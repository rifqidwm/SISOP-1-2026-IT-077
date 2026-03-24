# SISOP-1-2026-IT-077

Rifqi Dwi Muslim | 5027251077

---

## Struktur Direktori

Repository ini terdiri dari 2 folder utama berdasarkan soal yang telah selesai dikerjakan:

```
.
├── soal_1/
│   ├── KANJ.sh
│   └── passenger.csv
└── soal_2/
    └── ekspedisi/
        ├── peta-ekspedisi-amba.pdf
        └── peta-gunung-kawi/
            ├── gsxtrack.json
            ├── parserkoordinat.sh
            ├── nemupusaka.sh
            ├── titik-penting.txt
            └── posisipusaka.txt
```

---

## Soal 1 - ARGO NGAWI JESGEJES

Soal pertama ini meminta kita untuk menganalisis data penumpang kereta KANJ dari file `passenger.csv` yang dilampirkan pada Spreadsheets dan diminta memakai `awk`. Semua perintah dimasukkan dalam 1 file `KANJ.sh` yang bisa dipanggil dengan opsi a, b, c, d, e.

Contoh cara pemanggilannya
```bash
awk -f KANJ.sh passenger.csv a
```

### Penjelasan

**Struktur kolom passenger.csv:**
```
Nama Penumpang, Usia, Kursi Kelas, Gerbong
```

`$1` = Nama Penumpang
`$2` = Usia
`$3` = Kursi Kelas
`$4` = Gerbong


**Bagian BEGIN:**
```awk
BEGIN {
    FS = ","
    opsi = ARGV[2]
    delete ARGV[2]
}
```
`FS = ","` memberitau awk pemisah kolom adalah koma, sesuai format csv.
 `ARGV[2]` saat script dipanggil dengan `awk -f KANJ.sh passenger.csv a`, awk membaca 3 hal, nama script, nama file data, dan opsi yang dipilih. Opsi `a/b/c/d/e` yang diketik di akhir tersimpan di `ARGV[2]`.
 `delete ARGV[2]` dipakai untuk menghapus opsi dari daftar argumen awk agar tidak dianggap sebagai nama file.


**Bagian NR > 1 (proses tiap baris):**
```awk
NR > 1 {
    if (opsi == "a") count++
    if (opsi == "b") gerbong[$4]++
    if (opsi == "c") {
        if ($2 > max_usia) { max_usia = $2; nama_tertua = $1 }
    }
    if (opsi == "d") { total_usia += $2; count++ }
    if (opsi == "e") { if ($3 == "Business") business++ }
}
```
`NR > 1` NR adalah nomor baris saat ini. Kondisi ini memastikan header dilewati
- **Opsi a** `count++` menambah counter setiap ada baris data, sehingga menghasilkan total penumpang
- **Opsi b** `gerbong[$4]++` menyimpan nama gerbong sebagai key array. Karena array tidak boleh duplikat, secara otomatis hanya menyimpan gerbong unik
- **Opsi c**  membandingkan `$2` (kolom usia) tiap baris dengan `max_usia`. Jika lebih besar, simpan usia dan nama penumpang tersebut
- **Opsi d** `total_usia += $2` menjumlahkan semua usia, `count++` menghitung jumlah penumpang untuk pembagi rata rata
- **Opsi e** cek apakah kolom `$3` bernilai "Business", kalau iya tambah counter `business`


**Bagian END (cetak hasil):**
```awk
END {
    if (opsi == "a") print "Jumlah seluruh penumpang KANJ adalah " count " orang"
    else if (opsi == "b") print "Jumlah gerbong penumpang KANJ adalah " length(gerbong)
    else if (opsi == "c") print nama_tertua " adalah penumpang kereta tertua dengan usia " max_usia " tahun"
    else if (opsi == "d") print "Rata-rata usia penumpang adalah " int(total_usia/count) " tahun"
    else if (opsi == "e") print "Jumlah penumpang business class ada " business " orang"
    else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f file.sh data.csv a"
    }
}
```
Blok `END` dijalankan sekali setelah semua baris selesai dibaca.
 `length(gerbong)`untuk  menghitung jumlah key yang ada di array gerbong, yaitu jumlah gerbong unik.
 `int(total_usia/count)` `int()` untuk membulatkan hasil bagi ke bawah tanpa angka di belakang koma.
 `else` digunakan untuk menampilkan pesan error jika opsi yang dimasukkan bukan a,b,c,d,e.

### Output

> Screenshot hasil menjalankan kelima opsi (a sampai e):

![output soal 1](./assets/soal1_output.png)

### Kendala

Tidak ada kendala

---

## Soal 2 - EKSPEDISI PESUGIHAN GUNUNG KAWI

Untuk soal ini alurnya mengunduh peta ekspedisi dari GDrive, lalu membaca isinya untuk menemukan link tersembunyi pada PDF, melakukan git clone dari link tersebut, mengekstrak koordinat dari file JSON dan menghitung titik tengahnya.

### Penjelasan

**1. Download PDF menggunakan gdown**

Sebelum menggunakan gdown, dibuat virtual environment terlebih dahulu agar instalasi package tidak mengganggu sistem
```bash
python3 -m venv myenv
source myenv/bin/activate
pip install gdown
```
`python3 -m venv myenv` membuat Python terisolasi bernama `myenv`.
kemudian `source myenv/bin/activate` mengaktifkan virtual environment.
 `pip install gdown` menginstall tool gdwon di dalam virtual environment

File PDF diunduh dengan
```bash
gdown 1q10pHSC3KFfvEiCN3V6PTroPR7YGHF6Q -O peta-ekspedisi-amba.pdf
```
`gdown`untuk mendownload file dari Gdrive
dan `-O` menentukan nama file output


**2. Menemukan link dari dalam PDF**

Dari hasil perintah gdwon ditemukan link github di paling bawah isinya, lalu clone
```bash
git clone https://github.com/pocongcyber77/peta-gunung-kawi.git peta-gunung-kawi
```

> Screenshot proses download dan clone:

![download dan clone](./assets/soal2_clone.png)



**3. parserkoordinat.sh**

Script ini untuk mengekstrak `id`, `site_name`, `latitude`, dan `longitude` dari `gsxtrack.json`:

```bash
#!/bin/bash

ids=$(grep '"id"' gsxtrack.json | grep "node_" | sed 's/.*"id": "\(.*\)".*/\1/')
names=$(grep '"site_name"' gsxtrack.json | sed 's/.*"site_name": "\(.*\)".*/\1/')
lats=$(grep '"latitude"' gsxtrack.json | sed 's/.*"latitude": \(.*\),/\1/')
lons=$(grep '"longitude"' gsxtrack.json | sed 's/.*"longitude": \(.*\),/\1/')

paste -d',' <(echo "$ids") <(echo "$names") <(echo "$lats") <(echo "$lons") > titik-penting.txt
```
- `grep '"id"'` mencari semua baris yang mengandung kata `"id"` dari file JSON
- `grep "node_"` memfilter lebih lanjut, hanya mengambil baris yang mengandung `node_` agar tidak ikut baris lain yang kebetulan ada kata "id"
- `sed 's/.*"id": "\(.*\)".*/\1/'` mengambil nilai antara tanda kutip setelah `"id": `. Bagian `\(.*\)` menangkap nilai itu, dan `\1` memanggilnya kembali
- `paste -d','` menggabungkan beberapa input menjadi 1 baris dengan pemisah koma
- `<(echo "$ids")` mengubah output variabel menjadi input yang bisa dibaca `paste`
- `> titik-penting.txt`menyimpan hasil ke file

> Screenshot isi titik-penting.txt:

![titik penting](./assets/soal2_titikpenting.png)



**4. nemupusaka.sh**

Script untuk menghitung titik tengah diagonal dari 4 koordinat yang ada di `titik-penting.txt`:

```bash
#!/bin/bash

baris1=$(head -1 titik-penting.txt)
baris2=$(head -2 titik-penting.txt | tail -1)
baris3=$(head -3 titik-penting.txt | tail -1)
baris4=$(head -4 titik-penting.txt | tail -1)

lat1=$(echo "$baris1" | cut -d',' -f3)
lon1=$(echo "$baris1" | cut -d',' -f4)
lat3=$(echo "$baris3" | cut -d',' -f3)
lon3=$(echo "$baris3" | cut -d',' -f4)

lat_tengah=$(echo "scale=6; ($lat1 + $lat3) / 2" | bc)
lon_tengah=$(echo "scale=6; ($lon1 + $lon3) / 2" | bc)

echo "$lat_tengah,$lon_tengah" > posisipusaka.txt
cat posisipusaka.txt
```
- `head -1` mengambil baris pertama dari file,
- `head -2 | tail -1` mengambil 2 baris pertama lalu ambil yang terakhir, hasilnya baris kedua.
- `cut -d',' -f3` memotong teks berdasarkan pemisah koma (`-d','`), ambil kolom 3 (`-f3`) yaitu latitude
- `echo "scale=6; ($lat1 + $lat3) / 2" | bc` menghitung rata rata pakai `bc`. `scale=6` menentukan 6 angka di belakang koma

Titik tengah dihitung dari node_001 dan node_003 karena keduanya adalah titik diagonal yang berseberangan

> Screenshot isi posisipusaka.txt dan verifikasi di Google Maps:

![posisi pusaka](./assets/soal2_posisipusaka.png)

### Kendala

Tidak ada kendala
