# Dokumentasi

Semua hasil riset & dokumentasi untuk project Cut & Fill AutoCAD.

| File | Isi |
|---|---|
| [CUT-AND-FILL-LISP.md](CUT-AND-FILL-LISP.md) | Dokumentasi LISP `src/cutfill.lsp`: command, rumus, input/output, verifikasi |
| [CUT-AND-FILL-WORKFLOW.md](CUT-AND-FILL-WORKFLOW.md) | Panduan menggambar rencana cut & fill + konvensi layer |
| [CROSS-SECTION-LISP.md](CROSS-SECTION-LISP.md) | Temuan LISP cross section yang sudah ada di workspace lama |
| [CIVIL3D-2021-MCP.md](CIVIL3D-2021-MCP.md) | Data inventaris AutoCAD 2021 & Civil 3D 2021 + rancangan MCP |

---

## Ringkasan Temuan Utama

### 1. Cross Section — sudah ada LISP, tapi tidak ada hitungan volume

| File | Perintah | Fungsi |
|---|---|---|
| `rdg.lsp` | `RDG` | Gambar cross section jalan/pipa (paling lengkap, ada ordinat) |
| `S.LSP` | `S` | Label cross section otomatis per file |
| `supperelevation.LSP` | `SUP` | Cross section + superelevasi |
| `rr.lsp` / `OFFICE_LSP.lsp` | `CT2` | Cross section pipa |

> ⚠️ Semuanya **hanya menggambar**, **tidak ada** yang menghitung volume cut & fill.

Detail: [CROSS-SECTION-LISP.md](CROSS-SECTION-LISP.md)

### 2. Cut & Fill — dibuat baru

Tidak ada LISP hitungan cut & fill di 631 file workspace lama.
Karena itu `src/cutfill.lsp` dibuat dari nol dengan rumus terverifikasi.

Detail: [CUT-AND-FILL-LISP.md](CUT-AND-FILL-LISP.md)

### 3. Software di PC ini

- **AutoCAD 2021** ✅ terinstall
- **Civil 3D 2021** ✅ terinstall sebagai **modul di dalam AutoCAD 2021**
  (tidak ada `Civil3D.exe` terpisah — command C3D dipanggil lewat `acad.exe`)
- **MCP server** ⏸ belum dibuat (menunggu gambar rencana selesai)

Detail: [CIVIL3D-2021-MCP.md](CIVIL3D-2021-MCP.md)

---

## Sumber Riset

```
D:\Projectmcp\Cad Project\LISP Autocad\     631 file .lsp/.vlx/.fas
D:\Projectmcp\Cad Project\tools\*.json       database inventaris LISP
D:\Projectmcp\Cad Project\docs-notes-fungsi\ catatan fungsi per kategori
```

Tanggal riset: 27 September 2026
