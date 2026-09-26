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

## Rencana Konten

- LISP hitung volume cut & fill per station
- Kompatibel dengan input/output `rdg.lsp` (chain length, ordinat kiri/kanan, tinggi jalan)
- Laporan volume (m³) per station + total kumulatif

## Lisensi

TBD
