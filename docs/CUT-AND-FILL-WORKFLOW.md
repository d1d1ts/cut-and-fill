# Workflow: Menggambar Rencana Cut & Fill

Panduan untuk menggambar rencana galian & timbun agar mudah diproses
oleh LISP `CUTFILL` atau MCP server nanti.

---

## Konvensi Layer yang Disarankan

| Layer | Isi | Warna | Lineweight |
|---|---|---|---|
| `CUT` | Polyline/zona **galian** | Merah | 0.50 |
| `FILL` | Polyline/zona **timbun** | Hijau | 0.50 |
| `ESEGMENT` | Garis cross section per station | Kuning | 0.25 |
| `SPOT` | Titik elevasi terreno | Putih | — |
| `DESIGN` | Garis grade / formasi | Magenta | 0.35 |
| `CUTFILL` | Table hasil hitungan | (otomatis) | — |
| `ANNOT` | Label, chainage, teks | Biru | 0.18 |

> Layer `CUTFILL` dibuat **otomatis** oleh LISP — tidak perlu dibuat manual.

---

## Format Objek yang Paling Mudah Diproses

### 1. Zona Cut / Fill

- **Satu polyline tertutup per zona**
- Jangan pecah jadi banyak polyline kecil
- Beri **nama** yang jelas, misal: `ZONECUT-01`

Cara set nama polyline di AutoCAD:
```
PEDIT → pilih polyline → M (Move) → isi nama
```

### 2. Titik Elevasi Terreno

Pilihan (pilih salah satu, konsisten):

| Cara | Cara setting | Cara baca |
|---|---|---|
| **A. POINT 3D** | `POINT` → Z = elevasi | `assoc 38` (group 38 = elevasi) |
| **B. TEXT** | text `E=12.345` | baca string, parse angka |
| **C. Block** | block dengan attribut | baca DXF table |

**Rekomendasi: Cara A (POINT 3D)** — paling bersih, langsung punya koordinat Z.

Contoh di LISP:
```lisp
(setq d (entget ent))
(setq z (cdr (assoc 38 d)))   ; elevasi point
(setq x (cdr (assoc 10 d)))   ; koordinat (x y z)
```

### 3. Cross Section (ESEGMENT)

- Satu **polyline** per station
- Beri nama dengan format chainage: `STA-0+000`, `STA-0+020`, dst
- Mengandung titik kiri, tengah, kanan (minimal 3 titik)

### 4. Label Station

Format yang disarankan:
```
STA 0+000      atau      0+000
STA 0+020              0+020
```

---

## Format Chainage

| Format | Contoh | Catangan |
|---|---|---|
| **Meter desimal** | `20`, `40`, `100` | ✅ Paling mudah diproses |
| Chainage abbreviate | `0+020` | Perlu parsing pemisah `+` |
| Station label | `STA 0+020` | Ambil bagian numeriknya |

> **Saran:** pakai **meter desimal** untuk data yang akan diproses LISP,
> dan chainage abbreviate hanya untuk label tampilan di gambar.

---

## Contoh Workflow

### Step 1 — Gambar permukaan terreno
```
Buat polyline tertutup untuk area kerja
Elevation: 0 (default, atau set manual)
```

### Step 2 — Gambar garis design/grade
```
Garis polyline di layer DESIGN, elevasi tetap (Z = elevasi formasi)
```

### Step 3 — Taruh titik spot elevasi
```
POINT di layer SPOT, isi koordinat Z = elevasi terreno di titik itu
```

### Step 4 — Gambar cross section
```
 Satu polyline per station di layer ESEGMENT
 Minimal 3 titik: kiri, tengah, kanan
```

### Step 5 — Datakan ke format LISP
Buat file `.txt` (pisah koma):
```
; chain, elev-kiri, elev-tengah, elev-kanan
0, 11.0, 10.0, 11.0
20, 8.0, 7.0, 8.0
40, 5.0, 4.0, 5.0
```

### Step 6 — Hitung volume
```lisp
CUTFILLFILE
```
Atau interaktif:
```lisp
CUTFILL
```

---

## Tips Praktis

| Tips | Detail |
|---|---|
| **Gunakan Object Snap** | `OSMODE` = 8 (Node) + 32 (Endpoint) agar presisi |
| **Gunakan UCS lokal** | Easier saat menggambar cross section |
| **Bekukan layer** | Setelah selesai, `FREEZE` layer agar tidak salah edit |
| **Simpan berkala** | `Ctrl+S` — jangan sampai data hilang |
| **Pakai BLOCK** | Untuk simbol berulang, lebih ringan daripada copy |

---

## Jika Gambar Sudah Jadi

Untuk koneksi ke MCP server (saat dibuat), kemungkinan alurnya:
1. MCP baca layer `CUT` / `FILL` → polyline
2. MCP baca layer `SPOT` → titik + Z
3. MCP hitung volume otomatis
4. MCP tulis table di layer `CUTFILL`

Lihat: file `CIVIL3D-2021-MCP.md` untuk detail arsitektur MCP.

---

## Checklist Sebelum Hitung

- [ ] Layer `CUT` & `FILL` sudah ada polyline tertutup
- [ ] Layer `SPOT` sudah berisi titik dengan Z
- [ ] Chainage terurut naik (sta 0 → 100 → 200)
- [ ] Elevasi dalam **meter** (bukan mm)
- [ ] Side slope & lebar bahu sudah ditentukan
- [ ] Kalau pakai `CUTFILLFILE`, file `.txt` sudah siap

---

## Referensi

| File | Isi |
|---|---|
| `CUT-AND-FILL-LISP.md` | Dokumentasi LISP lengkap |
| `CROSS-SECTION-LISP.md` | LISP cross section lama di workspace |
| `CIVIL3D-2021-MCP.md` | Data inventaris AutoCAD & Civil 3D 2021 |
