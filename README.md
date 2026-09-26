# Cut & Fill — AutoCAD LISP

Kumpulan LISP (AutoLISP) untuk perhitungan **cut & fill (galian / timbun)** pada gambar AutoCAD.

## Status

Repositori sedang disiapkan. LISP pertama belum dibuat.

## Latar Belakang

Kumpulan LISP AutoCAD yang ada di folder `../LISP Autocad` sudah covering banyak hal
(annotasi, layer, tabel, drafting), **tetapi belum ada** LISP khusus hitungan cut & fill.

Yang terkait tapi **bukan** hitungan cut & fill:

| File | Perintah | Fungsi sebenarnya |
|---|---|---|
| `rdg.lsp` | `RDG` | Menggambar cross section jalan / pipa (tanpa hitung volume) |
| `supperelevation.LSP` | `SUP` | Cross section jalan + superelevasi (tanpa hitung volume) |
| `TerrainSectionsPro2X.lsp` | `TERS`, `TERY` | Interpolasi elevasi terrain (data helper) |
| `cut.lsp` | `CUT`, `SCB` | Multi-trim / potong objek (bukan cut & fill) |
| `excavation.lsp` | `MUCS`, `UC` | Alat bantu gambar galian (bukan hitung volume) |

Jadi LISP di repo ini akan dibuat baru, dengan acuan kompatibilitas output `rdg.lsp`.

## Fitur

Perhitungan **cut & fill (galian / timbun)** metode **Average End Area**.

| Command | Fungsi |
|---|---|
| `CUTFILL` | Input interaktif per station, langsung dapat table di gambar |
| `CUTFILLFILE` | Batch dari file `.txt` / `.csv` |
| `CUTDEMO` | Buat file data contoh untuk uji coba |

### Rumus

Lebar horizontal lereng = `side slope (H:V) x kedalaman`

Luas satu sisi (wedge):
```
A = side_slope * (d_tepi + d_sumbu)^2 / 4
```

Volume antar station:
```
V = (Luas_1 + Luas_2) / 2 x jarak
```

### Input tiap station

- Chainage (m)
- Elevasi terreno kiri, tengah, kanan (m)
- Lebar bahu kiri & kanan (m)
- Side slope H:V

### Output

Table di layer `CUTFILL`: STA, chainage, A.CUT, A.FILL, V.CUT, V.FILL, CUM.CUT, CUM.FILL
Ditambah baris total volume cut & fill dalam m³.

### Konvensi tanda

| Tanda | Arti |
|---|---|
| Depth positif | **CUT** (galian) |
| Depth negatif | **FILL** (timbun) |

### Format file (untuk `CUTFILLFILE`)

```
; chain, elev-kiri, elev-tengah, elev-kanan
0, 11.0, 10.0, 11.0
20, 8.0, 7.0, 8.0
40, 5.0, 4.0, 5.0
```

Pemisah boleh koma, spasi, atau tab. Baris `;` = komentar.

## Cara Pakai

```
1. (load "D:/Projectmcp/Cad Project/cut&fill/src/cutfill.lsp")
2. CUTFILL     ; atau CUTFILLFILE, atau CUTDEMO dulu untuk uji
3. Jawab prompt, klik titik penempatan table
```

Uji cepat tanpa AutoCAD (verifikasi rumus):
```
python test/verify.py
```

## Catatan Teknis

- LISP **sudah diverifikasi balance** (kurung kurung seimbang) dan rumusnya
  diuji lewat `test/verify.py` (port identik ke Python).
- Memakai `entmakex` untuk table, bukan `command`, supaya lebih stabil.
- AutoCAD native: `entmakex` tersedia di AutoCAD 2000+ tanpa perlu VLISP load.

## Lisensi

TBD
