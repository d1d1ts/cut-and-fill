# Temuan: LISP Cross Section di Koleksi AutoCAD

**Tanggal riset:** 27 September 2026
**Sumber:** `D:\Projectmcp\Cad Project\LISP Autocad\` (631 file .lsp/.vlx/.fas)
**Metode:** pencarian nama file, isi file, dan database JSON (`tools\lisp_*.json`)

---

## Ringkasan

Ditemukan **4 file LISP** yang mengandung kata "cross section".
Tidak ada LISP yang menghitung volume cut & fill.

---

## 1. `rdg.lsp` — perintah `RDG` (PALING RELEVAN)

**Lokasi**
```
D:\Projectmcp\Cad Project\LISP Autocad\rdg.lsp
```

**Fungsi:** menggambar *graph* / cross section untuk jalan dan pipeline.

**Bukti kata "cross section" (line 30, 328):**
```lisp
(setq chain_l (GETSTRING "\n CROSS SECTION AT CHAIN LENGTH (IN METRES)?"))
...
(command "text" "style" "lab" "C" ... (STRCAT "%%uCROSS SECTION AT CHAIN LENGTH " chain_l " m") "")
```

**Input (urutan prompt):**

| Prompt | Arti |
|---|---|
| `HORIZONTAL SCALE ?` | Skala horizontal |
| `VERTICAL SCALE ?` | Skala vertikal |
| `HOW MANY GRAPHS DO YOU WANT IN THIS SESSION ?` | Jumlah station |
| `BLACK TOP HALF WIDTH LEFT (IN METRES)?` | Lebar bahu kiri |
| `BLACK TOP HALF WIDTH RIGHT (IN METRES)?` | Lebar bahu kanan |
| `BERM WIDTH FROM BLACK TOP EDGE (IN METRES)?` | Lebar berm |
| `PIPELINE TO LEFT OR RIGHT (L/R)` | Posisi pipeline |
| `DISTANCE OF PIPE CEN. FROM BLACK TOP EDGE` | Jarak centerline pipa |
| `WHERE DO YOU WANT THE GRAPH?` | Titik penempatan (loop per station) |
| `CROSS SECTION AT CHAIN LENGTH (IN METRES)?` | Chainage station |
| `DATUM (IN METRES)?` | Datum elevasi |
| `HT. AT ROAD CENTRE (IN METRES)?` | Tinggi di sumbu jalan |
| `HT. AT PIPELINE CENTRE` | Tinggi di sumbu pipa |
| `HT. AT BLACK TOP EDGE LEFT/RIGHT` | Tinggi tepi bahu |
| `HT. AT BERM EDGE LEFT/RIGHT` | Tinggi tepi berm |
| `HOW MANY ORDINATES TO THE LEFT/RIGHT` | Jumlah ordinat tiap sisi |

**Konsekuensi penting:** LISP ini menghasilkan **geometri + label**, **TIDAK** menghitung volume.
Perhitungan cut & fill harus dilakukan terpisah dari ordinat yang diinput.


---

## 2. `S.LSP` — perintah `S`

**Lokasi**
```
D:\Projectmcp\Cad Project\LISP Autocad\S.LSP
```

**Fungsi:** mengganti teks pada layer `cs` menjadi label cross section.
Berjalan berurutan (chainage naik) dan menghasilkan file `.dwg` per section.

**Inti kode (line 78-80):**
```lisp
(setq cs1 (ssget "x" '((0 . "text")(8 . "cs"))))
(setq cst (strcat "CROSS SECTION" "@" fin1 "Km"))
(COMMAND "CHANGE" cs1 "" "" "" "" "" "" cst)
```

Label menjadi: `CROSS SECTION@<namafile>Km`

---

## 3. `supperelevation.LSP` — perintah `SUP`

**Lokasi**
```
D:\Projectmcp\Cad Project\LISP Autocad\supperelevation.LSP
```

**Fungsi:** cross section jalan dengan **superelevasi** (visi landai).
Jumlah kemunculan "cross section" = 6 (paling banyak).

**Input:**
```
enter length of superelevation:
enter right cross section slop of the begining(+% or -%):
enter left  cross section slop of the begining(+% or -%):
enter right cross section slop of the end(+% or -%):
enter left  cross section slop of the end(+% or -%):
enter right width:
enter left width:
```

**Logika inti:**
```lisp
(setq dh(-(- 0.2(min(/(* wr sr)100)(/(* wl sl)100)(/(* tr wr)100)(/(* tl wl)100)))))
```

**Perintah AutoCAD yang dipakai:** `line`, `zoom w`, `ucs new 3p`, `text`.

**Catatan:** juga tidak menghitung volume.

---

## 4. `rr.lsp` dan `OFFICE_LSP.lsp` — perintah `CT2`

**Lokasi**
```
D:\Projectmcp\Cad Project\LISP Autocad\rr.lsp         (line 2955)
D:\Projectmcp\Cad Project\LISP Autocad\OFFICE_LSP.lsp (line 4405)
```

**Fungsi:** cross section **pipa** (pipe cross section).

**Komentar di source (identik di kedua file):**
```lisp
;;; Pipe cross section !.
(defun c:CT2(/ osm e ent1 e1 pt1 r1 pt2 pt3 pt4 pt5 pt6 en1 en2 en3 en4)
   (setvar "cmdecho" 0)
   ...
```

**Catatan:** isi kedua file pada bagian ini **identik** — kemungkinan `OFFICE_LSP.lsp`
adalah gabungan beberapa LISP (termasuk `rr.lsp`).

---

## File yang NAMANYA mirip tapi BUKAN cross section

| File | Perintah | Kenapa bukan |
|---|---|---|
| `cut.lsp` | `CUT`, `SCB`, `SC`, `SCD`, `BIGTRIM`, `RECTRIM` | Multi-trim (potong objek di luar/dalam persegi). "cut" = *memotong*, bukan *galian*. |
| `sfill.lsp` | `SFILL` | Membagi bidang SOLID evenly antar 2 polyline. "fill" = *mengisi solid*, bukan *timbunan*. |
| `TRIMM.LSP` | — | Trim dengan cutting edges. |
| `CUTDIM*.LSP` | — | Memotong objek dimensi. |
| `(CUT) CREATE VIEWPORT (vc).LSP` | — | Memotong viewport. |
| `ocd Boundry Cut.LSP` | — | Memotong boundary. |
| `excavation.lsp` | `MUCS`, `UC`, `AA`, `A`, `XV`, `LO`, `CHO`, `MC` | Alat bantu gambar galian (UCS elevasi, offset, choe, move). **Tidak ada hitungan volume.** |
| `resection.lsp` | — | Resection (geodesi), bukan "section". |
| `crossref.lsp` | — | Cross-reference, bukan cross section. |
| `TerrainSectionsPro2X.lsp` | `TERS`, `TERY` | Interpolasi elevasi terrain (helper), bukan gambar section. |

---

## File pendukung (bukan cross section, tapi berguna)

| File | Perintah | Fungsi |
|---|---|---|
| `Stn-Elev.lsp` | — | Station & elevation |
| `Stn-Elev-V0.lsp` | — | Versi lama |
| `profiling10.lsp` | `PRO` | Profil jalan/ground dari station + elevation |
| `profiles.lsp` | `LISTPROFILENAMES` | Daftar profil |
| `profile WATER.LSP` | `CV`, `D`, `ML`, `TS`, `CU` | Profil water |
| `PO for profiles.lsp` | `PO` | Point ordinates untuk profil |
| `vertical curve.LSP` | `VERTI` | Vertical curve (perpendikatan) |
| `level calculation.LSP` | — | Perhitungan level |
| `level calculation with scale.LSP` | — | Level dengan skala |
| `slope calculation.LSP` | — | Perhitungan kemiringan |
| `Slope.lsp` | — | Kemiringan |

---

## Kesimpulan

> **Belum ada LISP hitungan cut & fill di koleksi ini.**
> `rdg.lsp` adalah yang paling dekat — ia menghasilkan cross section lengkap
> dengan ordinat, tetapi **tidak** menghitung volume galian/timbun.
>
> **Catatan:** sudah ada LISP cross section di workspace lama
> (lihat `CROSS-SECTION-LISP.md`) — tapi tidak ada yang menghitung volume.
> Karena itu LISP ini dibuat baru.

---

## Cara memanggil ulang dari AutoCAD

```lisp
(load "D:/Projectmcp/Cad Project/LISP Autocad/rdg.lsp")
RDG
```

> Nama folder mengandung spasi (`Cad Project`, `LISP Autocad`) —
> path harus diapit tanda kutip.


