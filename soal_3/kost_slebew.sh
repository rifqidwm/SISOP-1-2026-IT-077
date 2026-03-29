#!/bin/bash

DATA_FILE="data/penghuni.csv"
HISTORY_FILE="sampah/history_hapus.csv"
LOG_FILE="log/tagihan.log"
REKAP_FILE="rekap/laporan_bulanan.txt"

# Buat folder dan file kalau belum ada
mkdir -p data sampah log rekap

if [ ! -f "$DATA_FILE" ]; then
    echo "nama,kamar,harga_sewa,tanggal_masuk,status" > "$DATA_FILE"
fi

if [ ! -f "$HISTORY_FILE" ]; then
    echo "nama,kamar,harga_sewa,tanggal_masuk,status,tanggal_hapus" > "$HISTORY_FILE"
fi

# ============================================
# OPSI 1 - TAMBAH PENGHUNI
# ============================================
tambah_penghuni() {
    echo "============================================"
    echo "              TAMBAH PENGHUNI"
    echo "============================================"

    read -p "Masukkan Nama: " nama
    read -p "Masukkan Kamar: " kamar

    # Validasi kamar unik
    if awk -F',' -v k="$kamar" 'NR > 1 { if ($2 == k) found=1 } END { exit !found }' "$DATA_FILE" 2>/dev/null; then
        echo "[X] Kamar $kamar sudah ditempati!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -p "Masukkan Harga Sewa: " harga

    # Validasi harga positif
    if ! [[ "$harga" =~ ^[0-9]+$ ]] || [ "$harga" -le 0 ]; then
        echo "[X] Harga sewa harus angka positif!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal

    # Validasi format tanggal
    if [[ ! "$tanggal" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "[X] Format tanggal salah! Gunakan format YYYY-MM-DD"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Validasi tanggal tidak boleh masa depan
    today=$(date +%Y-%m-%d)
    if [[ "$tanggal" > "$today" ]]; then
        echo "[X] Tanggal tidak boleh melebihi hari ini!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -p "Masukkan Status Awal (Aktif/Menunggak): " status

    # Validasi status
    if [[ "$status" != "Aktif" && "$status" != "Menunggak" ]]; then
        echo "[X] Status harus Aktif atau Menunggak!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    echo "$nama,$kamar,$harga,$tanggal,$status" >> "$DATA_FILE"
    echo ""
    echo "[√] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status."
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================
# OPSI 2 - HAPUS PENGHUNI
# ============================================
hapus_penghuni() {
    echo "============================================"
    echo "              HAPUS PENGHUNI"
    echo "============================================"

    read -p "Masukkan nama penghuni yang akan dihapus: " nama

    # Cek apakah nama ada
    if ! awk -F',' -v n="$nama" 'NR > 1 { if ($1 == n) found=1 } END { exit !found }' "$DATA_FILE" 2>/dev/null; then
        echo "[X] Penghuni \"$nama\" tidak ditemukan!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    today=$(date +%Y-%m-%d)

    # Pindahkan ke history_hapus.csv dulu
    awk -F',' -v n="$nama" -v d="$today" \
        'NR > 1 && $1 == n { print $0","d }' "$DATA_FILE" >> "$HISTORY_FILE"

    # Hapus dari database utama
    awk -F',' -v n="$nama" \
        'NR == 1 || $1 != n { print }' "$DATA_FILE" > /tmp/temp_penghuni.csv
    mv /tmp/temp_penghuni.csv "$DATA_FILE"

    echo ""
    echo "[√] Data penghuni \"$nama\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================
# OPSI 3 - TAMPILKAN DAFTAR PENGHUNI
# ============================================
tampilkan_penghuni() {
    echo "============================================"
    echo "       DAFTAR PENGHUNI KOST SLEBEW"
    echo "============================================"
    printf "%-4s| %-20s| %-6s| %-15s| %s\n" "No" "Nama" "Kamar" "Harga Sewa" "Status"
    echo "------------------------------------------------------------"

    awk -F',' '
    NR > 1 {
        count++
        printf "%-4s| %-20s| %-6s| %-15s| %s\n", count, $1, $2, "Rp"$3, $5
    }
    ' "$DATA_FILE"

    echo "------------------------------------------------------------"

    awk -F',' '
    NR > 1 {
        total++
        if ($5 == "Aktif") aktif++
        else menunggak++
    }
    END {
        printf "Total: %s penghuni | Aktif: %s | Menunggak: %s\n", total, aktif, menunggak
    }
    ' "$DATA_FILE"

    echo "============================================"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================
# MAIN MENU
# ============================================
while true; do
    clear
    echo "============================================"
    echo "       SISTEM MANAJEMEN KOST SLEBEW"
    echo "============================================"
    echo " ID | OPTION"
    echo "--------------------------------------------"
    echo "  1 | Tambah Penghuni Baru"
    echo "  2 | Hapus Penghuni"
    echo "  3 | Tampilkan Daftar Penghuni"
    echo "  4 | Exit Program"
    echo "============================================"
    read -p "Enter option [1-4]: " opsi

    case $opsi in
        1) tambah_penghuni ;;
        2) hapus_penghuni ;;
        3) tampilkan_penghuni ;;
        4) echo "Sampai jumpa!"; exit 0 ;;
        *) echo "Pilihan tidak valid!"; read -p "Tekan [ENTER]..." ;;
    esac
done
