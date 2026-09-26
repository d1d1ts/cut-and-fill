# Temuan: AutoCAD 2021 & Civil 3D 2021 di PC Ini

**Tanggal riset:** 27 September 2026
**Tujuan:** data inventaris untuk pembuatan MCP (Model Context Protocol) server

---

## Ringkasan

| Produk | Status | Detail |
|---|---|---|
| **AutoCAD 2021** | ✅ Terinstall | `C:\Program Files\Autodesk\AutoCAD 2021\acad.exe` |
| **Civil 3D 2021** | ⚠️ Ter-install sbg **modul di AutoCAD 2021** | `C:\Program Files\Autodesk\AutoCAD 2021\C3D\` |
| **`accoreconsole.exe`** | ✅ Ada (headless) | Untuk testing tanpa GUI |
| **Dynamo Core 2.5** | ✅ Ada | `C3D\Dynamo\Core\DynamoSandbox.exe` |

**Temuan kunci:** tidak ada `Civil3D.exe` terpisah.
Civil 3D 2021 berjalan **di dalam** AutoCAD 2021 (model deployment "AutoCAD-based install").
Jadi command Civil 3D dipanggil lewat `acad.exe`.

---

## 1. AutoCAD 2021

```
C:\Program Files\Autodesk\AutoCAD 2021\acad.exe
```

Registry: `HKLM\SOFTWARE\Autodesk\AutoCAD\R24.0` → AcadLocation
(R24.0 = versi 2021)

**Exe penting di folder yang sama:**

| File | Fungsi |
|---|---|
| `acad.exe` | Aplikasi utama |
| `accoreconsole.exe` | **Core console** — jalan script/LISP tanpa GUI |
| `AutoLispDebugAdapter.exe` | Debugger LISP |
| `AcTranslators.exe` | Konversi format |
| `DwgCheckStandards.exe` | Cek standar DWG |
| `DADispatcherService.exe` | Autodesk Download Assistant |

---

## 2. Civil 3D 2021 (sebagai modul)

**Lokasi modul:**
```
C:\Program Files\Autodesk\AutoCAD 2021\C3D\
```

**Registry entry:**
```
HKLM\SOFTWARE\Autodesk\Autodesk Civil 3D 2021 - English
HKLM\SOFTWARE\Autodesk\Civil View
```

Versi lain yang pernah terinstall (registry):
```
Autodesk Civil 3D 2019 - English
Autodesk Civil 3D 2020 - English UK
Autodesk Civil 3D 2021 - English          ← yang dipakai
Autodesk Civil 3D 2021 Object Enabler
```

### Interop .NET (penting untuk MCP berbasis .NET)

```
Autodesk.AECC.Interop.Land.dll
Autodesk.AECC.Interop.Pipe.dll
Autodesk.AECC.Interop.Roadway.dll
Autodesk.AECC.Interop.Survey.dll
Autodesk.AECC.Interop.UiLand.dll
Autodesk.AECC.Interop.UiPipe.dll
Autodesk.AECC.Interop.UiRoadway.dll
Autodesk.AECC.Interop.UiSurvey.dll
```

### Managed DLL (.NET)

| File | Isi |
|---|---|
| `AeccDbMgd.dll` | Autodesk Database (objects) |
| `AeccCogoMgd.dll` | COGO / traverse |
| `AeccMgdReverse.dll` | Reverse engineering bridge |
| `C3D_RailNETWrapper.dll` | Rail |
| `C3D_RdbNETWrapper.dll` | RAIL alignment descriptor |

### Object DBX (fitur per modul)

| File | Isi |
|---|---|
| `AeccLand.dbx` | Grading / earthwork |
| `AeccRoadway.dbx` | Alignment, profile, corridor |
| `AeccSurvey.dbx` | Points, surfaces, COGO |
| `AeccPressurePipes.dbx` | Jaringan pipa |
| `AeccBuildingSite.dbx` | Site |
| `AeccHydrology.dbx` | Hydrologi |
| `AeccWatersheds.dbx` | Watershed |
| `AeccCoreBase.crx` | Core |

### Fitur earthwork & surface (relevan untuk cut & fill)

```
AeccEarthWorkPlan.dll       — Perencanaan earthwork
AeccEarthWorkPlan.dll.config
AeccSurface.dll
AeccDEMReader.dll
AeccPointCloud.dbx
AeccSurfaceToSolids.arx
```

### Report & I/O

```
AeccReportsX.dll
AeccExportCivilDrawing.crx
LandXMLSDK1.2.dll            — LandXML export/import
CVE.Data.Civil.dll
CVE.Data.Vesper.dll
```

### Lain-lain

```
AeccDynamo.dll
AeccDynamoCmd.dll
ShortcutEditor.exe
Newtonsoft.Json.dll
System.Data.SQLite.dll / EmbeddedSQLiteLoader.dll
```

---

## 3. Dynamo Core 2.5

```
C:\Program Files\Autodesk\AutoCAD 2021\C3D\Dynamo\Core\DynamoSandbox.exe
C:\ProgramData\Dynamo\Dynamo Core\2.5\packages\GenerativeDesign\
```

GenerativeDesign berisi beberapa `.dll` (DotNetEnv, GenerativeDesignFunctions,
GenerativeDesignNodes, PrimitiveGeometry, websocket-sharp) + terjemahan 16 bahasa.

> Catatan: Dynamo ada, tapi untuk Cut & Fill **tidak perlu** — LISP + COM API sudah cukup.

---

## 4. AutoCAD lain yang terinstall

```
C:\Program Files\Autodesk\AutoCAD 2019
C:\Program Files\Autodesk\AutoCAD 2021     ← dipakai
C:\Program Files\Autodesk\AutoCAD 2024
```

> Kalau MCP terhubung ke AutoCAD, pastikan **ProgID** yang dipakai sesuai
> versi yang aktif (`AutoCAD.Application.24.0` untuk 2021).

---

## 5. Konfigurasi MCP saat ini

```
C:\Users\ASUS\.cline\data\settings\cline_mcp_settings.json
{ "mcpServers": {} }
```

**Status: KOSONG** — belum ada MCP server terdaftar untuk Cline.

File MCP lain di sistem (milik tool lain, tidak terkait):
```
C:\Users\ASUS\.gemini\config\mcp_config.json
C:\Users\ASUS\.gemini\antigravity-ide\mcp_config.json
C:\Users\ASUS\.gemini\antigravity-backup\mcp_config.json
```

---

## 6. GitHub account di PC ini

```
Username : d1d1ts
Simpan   : Windows Credential Manager
           (cmdkey: "GitHub - https://api.github.com/d1d1ts")
```

Repo yang ter-clone di `D:\Projectmcp`:

| Path | Remote |
|---|---|
| `D:\Projectmcp\agency-agents` | `msitarzewski/agency-agents` |
| `D:\Projectmcp\decoluaatau9router` | `decolua/9router` |
| `D:\Projectmcp\freellmapi\freellmapi` | `tashfeenahmed/freellmapi` |
| `D:\Projectmcp\Cad Project\cut&fill` | `d1d1ts/cut-and-fill` (punyak user) |

---

## 7. Usulan arsitektur MCP (untuk cut & fill)

```
Cline  ──►  MCP Server (Python)  ──►  COM Automation  ──►  acad.exe
                                              (pywin32 / win32com)
```

**Alasan pakai COM Automation:**
- AutoCAD & Civil 3D 2021 sudah expose full COM API (tidak perlu API key)
- `GetActiveObject("AutoCAD.Application.24.0")` → connect ke instance yang sedang dibuka
- Bisa kirim perintah C3D langsung (grading, surface, earthwork)
- Support `accoreconsole.exe` untuk operasi headless (batch, tanpa GUI)

**Tool MCP yang direncanakan:**

| Tool | Fungsi |
|---|---|
| `run_command` | Kirim perintah AutoCAD/LISP ke `acad.exe` |
| `run_lisp` | Eksekusi LISP (load `cutfill.lsp`, hitung volume) |
| `get_entities` | Baca objek (polyline, layer, elevasi, Z) |
| `get_layers` | Daftar layer |
| `earthwork_calc` | Hitung cut & fill via Civil 3D |
| `list_dwg` | Buka / simpan drawing |

> Detail arsitektur & implementasi MCP ditunda sampai gambar rencana
> cut & fill selesai, agar tool-nya sesuai kebutuhan aktual.

---

## 8. Verifikasi cepat

**Cek AutoCAD 2021 jalan:**
```powershell
& "C:\Program Files\Autodesk\AutoCAD 2021\acad.exe" /?
```

**Cek core console (headless), untuk uji LISP tanpa GUI:**
```powershell
& "C:\Program Files\Autodesk\AutoCAD 2021\accoreconsole.exe" /i test.dwg /s test.scr
```

**Lokasi LISP di Support Autodesk:**
```
C:\Program Files\Autodesk\AutoCAD 2021\C3D\Support\
```

---

## Daftar Path Penting

| Kebutuhan | Path |
|---|---|
| AutoCAD 2021 | `C:\Program Files\Autodesk\AutoCAD 2021\acad.exe` |
| Core console | `C:\Program Files\Autodesk\AutoCAD 2021\accoreconsole.exe` |
| Civil 3D modules | `C:\Program Files\Autodesk\AutoCAD 2021\C3D\` |
| LISP support C3D | `...\AutoCAD 2021\C3D\Support\` |
| Dynamo | `...\C3D\Dynamo\Core\DynamoSandbox.exe` |
| Workspace LISP lama | `D:\Projectmcp\Cad Project\LISP Autocad\` |
| Repo cut & fill | `D:\Projectmcp\Cad Project\cut&fill\` |

