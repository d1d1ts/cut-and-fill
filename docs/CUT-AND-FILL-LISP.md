# Dokumentasi LISP Cut & Fill

**File sumber:** `src/cutfill.lsp` (277 baris, 16 fungsi)
**Status:** rumus sudah diverifikasi lewat `test/verify.py`

---

## Command

| Command | Fungsi |
|---|---|
| `CUTFILL` | Input interaktif per station → table langsung di gambar |
| `CUTFILLFILE` | Batch dari file `.txt` / `.csv` |
| `CUTDEMO` | Bikin file data contoh untuk uji coba |

---

## Cara pakai

```lisp
(load "D:/Projectmcp/Cad Project/cut&fill/src/cutfill.lsp")
CUTFILL
```

Atau uji cepat tanpa AutoCAD:
```
python test/verify.py
```

---

## Rumus

**Lebar horizontal lereng** = `side slope (H:V) × kedalaman`

**Luas satu sisi (wedge antara tepi & sumbu):**
```
A = side_slope × (d_tepi + d_sumbu)² / 4
```

Penurunan:
```
lebar = sc × rata-rata kedalaman
      = sc × (d_tepi + d_sumbu) / 2

A = rata-rata kedalaman × lebar
  = (d_tepi + d_sumbu)/2 × sc×(d_tepi + d_sumbu)/2
  = sc × (d_tepi + d_sumbu)² / 4
```

**Volume antar station (Average End Area):**
```
V = (Luas_1 + Luas_2) / 2 × jarak
```

---

## Fungsi-fungsi LISP

| Fungsi | Isi |
|---|---|
| `cf:fmt` | Format angka 2 desimal |
| `cf:getr` | `getreal` dengan nilai default |
| `cf:geti` | `getint` dengan nilai default |
| `cf:nonneg` | Kunci nilai supaya tidak negatif |
| `cf:trap-half` | Luas satu sisi wedge |
| `cf:station` | Luas CUT, luas FILL, lebar puncak satu station |
| `cf:vol-between` | Volume antar 2 station |
| `cf:compute` | Loop utama semua station → baris hasil + total |
| `cf:ensure-layer` | Bikin layer otomatis kalau belum ada |
| `cf:draw-table` | Gambar table pakai `entmakex` |
| `cf:report` | Panggil table + baris total |
| `cf:load-file` | Baca file data |
| `cf:split` | Pecah string jadi token |
| `c:CUTFILL` | Command interaktif |
| `c:CUTFILLFILE` | Command dari file |
| `c:CUTDEMO` | Bikin file contoh |

---

## Input `CUTFILL`

| Prompt | Default | Arti |
|---|---|---|
| `Berapa banyak station` | 5 | Jumlah station |
| `Side slope H:V` | 2.0 | Kemiringan lereng (1 m horizontal : 2 m tinggi) |
| `Lebar bahu kiri (m)` | 3.0 | Lebar bahu kiri |
| `Lebar bahu kanan (m)` | 3.0 | Lebar bahu kanan |
| `Station N - CHAINAGE (m)` | — | Chainage station |
| `Elevasi terreno KIRI (m)` | 10.0 | Elevasi terreno kiri |
| `Elevasi terreno TENGAH (m)` | 10.0 | Elevasi terreno tengah |
| `Elevasi terreno KANAN (m)` | 10.0 | Elevasi terreno kanan |

---

## Output

Table diletakkan di layer `CUTFILL` (dibuat otomatis):

```
STA    CHAINAGE     A.CUT    A.FILL     V.CUT      V.FILL     CUM.CUT    CUM.FILL
1      0.00         1.00     0.00       0.00       0.00       0.00       0.00
2      20.00        1.00     0.00       20.00      0.00       20.00      0.00
...
TOTAL VOL.CUT = 100.00 m3    TOTAL VOL.FILL = 0.00 m3
```

| Kolom | Satuan | Arti |
|---|---|---|
| `STA` | — | Nomor station |
| `CHAINAGE` | m | Jarak station |
| `A.CUT` | m² | Luas penampang galian |
| `A.FILL` | m² | Luas penampang timbun |
| `V.CUT` | m³ | Volume galian dari station sebelumnya |
| `V.FILL` | m³ | Volume timbun dari station sebelumnya |
| `CUM.CUT` | m³ | Total galian kumulatif |
| `CUM.FILL` | m³ | Total timbun kumulatif |

> Baris `V.CUT` / `V.FILL` pada station **pertama** bernilai 0,
> karena belum ada station sebelumnya untuk dihitung jaraknya.

---

## Konvensi tanda

| Tanda | Arti |
|---|---|
| Depth **positif** (terreno lebih tinggi dari grade) | **CUT** (galian) |
| Depth **negatif** (terreno lebih rendah dari grade) | **FILL** (timbun) |

Bisa **campur** dalam satu station: sisi kiri cut, sisi kanan fill
(terreno miring). LISP otomatis memisahkan keduanya.

---

## Format file untuk `CUTFILLFILE`

```
; chain, elev-kiri, elev-tengah, elev-kanan
0, 11.0, 10.0, 11.0
20, 8.0, 7.0, 8.0
40, 5.0, 4.0, 5.0
60, 7.0, 6.0, 7.0
80, 9.0, 8.0, 9.0
100, 11.0, 10.0, 11.0
```

- Pemisah boleh **koma**, **spasi**, atau **tab**
- Baris diawali `;` = komentar, diabaikan
- Minimal 4 kolom per baris
- Lebar bahu & side slope diminta terpisah di prompt (dipakai untuk semua station)

---

## Verifikasi

`test/verify.py` adalah port identik logika LISP ke Python:

```python
def trap_half(d1, d2, sc):
    if sc > 0:
        return (sc * (d1 + d2) * (d1 + d2)) / 4.0
    return 0.0
```

**Hasil uji (6 station, 100 m, slope 1:2, d = 1 m):**
```
STA  CHAIN   A.CUT   A.FILL      V.CUT    V.FILL      CUM.CUT
  0     0.0     1.00     0.00       0.00       0.00         0.00
  1    20.0     1.00     0.00      20.00       0.00        20.00
  2    40.0     1.00     0.00      20.00       0.00        40.00
  3    60.0     1.00     0.00      20.00       0.00        60.00
  4    80.0     1.00     0.00      20.00       0.00        80.00
  5   100.0     1.00     0.00      20.00       0.00       100.00

TOTAL CUT  = 100.00 m3
TOTAL FILL = 0.00 m3
```

**Cek manual:** d = 1 m, slope 1:2 (H:V)
- tiap sisi: `1.0 × (2×1.0/2) / 2` = 0,50 m²
- dua sisi = **1,00 m²** ✓ cocok dengan `A.CUT`
- volume = 1,00 m² × 100 m = **100 m³** ✓

### Kasus campuran

| Kasus | A.CUT | A.FILL |
|---|---|---|
| homogen cut (zL=11, zC=10, zR=11) | 1.000 | 0.000 |
| homogen fill (zL=9, zC=10, zR=9) | 0.000 | 1.000 |
| campuran L-cut R-fill (zL=12, zC=10, zR=8) | 2.000 | 2.000 |

---

## Catatan Teknis

- Kurung kurung **sudah diverifikasi seimbang** (balance = 0)
- Memakai `entmakex`, bukan `command`, supaya lebih stabil
- `entmakex` tersedia di AutoCAD 2000+ tanpa perlu VLISP load
- Nama fungsi pakai prefix `cf:` agar tidak konflik dengan LISP lain
- Ukuran teks memakai `DIMSCALE`, ada fallback ke 3,5 / 4,0

---

## Batasan saat ini

| Batasan | Catatan |
|---|---|
| Lebar bahu & side slope | Sama untuk semua station (satu prompt) |
| Bentuk penampang | Simetris kiri-kanan, tanpa superelevasi |
| Gambar section | Belum di-generate otomatis (hanya table) |
| Kompleksitas | Objek Civil 3D (corridor) tidak didukung |
| Shrink/swell | Belum ada faktor pemampatan |

---

## Dokumentasi terkait

| File | Isi |
|---|---|
| `CROSS-SECTION-LISP.md` | LISP cross section yang sudah ada di workspace lama |
| `CIVIL3D-2021-MCP.md` | Data inventaris AutoCAD 2021 & Civil 3D 2021 |
| `CUT-AND-FILL-WORKFLOW.md` | Konvensi layer untuk gambar rencana cut & fill |

