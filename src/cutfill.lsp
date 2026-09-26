;;; ============================================================================
;;; cutfill.lsp  -  Hitungan CUT & FILL (galian / timbun) untuk AutoCAD
;;; ---------------------------------------------------------------------------
;;; Metode  : Average End Area (Trapezoidal) antar station
;;; Satuan  : panjang = meter, luas = m2, volume = m3
;;; Command : CUTFILL     -> input interaktif per station
;;;           CUTFILLFILE -> batch dari file .txt/.csv
;;;           CUTDEMO     -> buat file data contoh untuk uji coba
;;; ---------------------------------------------------------------------------
;;; CATATAN PENGGUNA:
;;;  - Depth positif = CUT  (tanah dibuang / galian)
;;;  - Depth negatif = FILL (tanah ditimbun)
;;;  - Crossfall     = kemiringan melintang tanah, dalam persen
;;;  - Side slope    = H : V  (1:2 -> 1 m horizontal tiap 2 m tinggi)
;;; ============================================================================


;;; ---------------------------------------------------------------------------
;;; Utilitas
;;; ---------------------------------------------------------------------------
(defun cf:fmt (n)
  "Format angka 2 desimal."
  (rtos n 2 2)
)

(defun cf:getr (pmsg def / v)
  "Getreal dengan nilai default."
  (initget 1)
  (setq v (getreal (strcat "\n" pmsg " <" (cf:fmt def) ">: ")))
  (if (null v) def v)
)

(defun cf:geti (pmsg def / v)
  "Getinteger dengan nilai default."
  (initget 1)
  (setq v (getint (strcat "\n" pmsg " <" (itoa def) ">: ")))
  (if (null v) def v)
)

(defun cf:nonneg (x)
  "Kunci nilai supaya tidak negatif."
  (if (> x 0.0) x 0.0)
)


;;; ---------------------------------------------------------------------------
;;; Perhitungan luas cross section
;;; ---------------------------------------------------------------------------
(defun cf:trap-half (d1 d2 sc)
  "Luas satu sisi (wedge lereng) antara tepi (d1) dan sumbu (d2).
   sc = side slope H:V, jadi lebar horizontal = sc * rata-rata kedalaman.
   A = (rata-rata kedalaman) x (lebar horizontal)
     = ((d1+d2)/2) * (sc*(d1+d2)/2)
     = sc*(d1+d2)^2 / 4"
  (if (> sc 0.0)
    (/ (* sc (+ d1 d2) (+ d1 d2)) 4.0)
    0.0))

(defun cf:station
  (zL zC zR bL bR sc
   / dL dR cL cR fL fR)
  "Hitung luas CUT, luas FILL, dan lebar puncak satu station.
   zL,zC,zR = tinggi terreno kiri / tengah / kanan
   bL,bR   = lebar bahu kiri / kanan (m)
   sc      = side slope H:V
   Hasil   : (list luas-cut luas-fill lebar-puncak-cut lebar-puncak-fill)"
  (setq dL (- zL zC)
        dR (- zR zC)
        cL (cf:nonneg dL)
        cR (cf:nonneg dR)
        fL (if (< dL 0.0) (- dL) 0.0)
        fR (if (< dR 0.0) (- dR) 0.0))
  (list
    (+ (cf:trap-half cL 0.0 sc) (cf:trap-half 0.0 cR sc))
    (+ (cf:trap-half fL 0.0 sc) (cf:trap-half 0.0 fR sc))
    (+ (* bL cL) (* bR cR))
    (+ (* bL fL) (* bR fR))))

(defun cf:vol-between (a1 a2 dist)
  "Volume antar station = (A1 + A2) / 2 x jarak."
  (* (/ (+ a1 a2) 2.0) dist))


;;; ---------------------------------------------------------------------------
;;; Perhitungan utama
;;; stations = list (stn chain zL zC zR bL bR)
;;; Return   : (list baris-hasil total-cut total-fill)
;;; ---------------------------------------------------------------------------
(defun cf:compute (stations sc / res cumC cumF prev st d vC vF ar row pCut pFill)
  (setq res nil
        cumC 0.0
        cumF 0.0
        prev nil)
  (foreach st stations
    (setq ar (cf:station (nth 2 st) (nth 3 st) (nth 4 st)
                         (nth 5 st) (nth 6 st) sc))
    (if prev
      (progn
        (setq d (- (nth 1 st) (nth 1 prev))
              vC (cf:vol-between (car prev) (nth 0 ar) d)
              vF (cf:vol-between (cadr prev) (nth 1 ar) d))
        (setq cumC (+ cumC vC)
              cumF (+ cumF vF)))
      (setq vC 0.0


;;; ---------------------------------------------------------------------------
;;; Pelaporan ke table AutoCAD
;;; ---------------------------------------------------------------------------
(defun cf:ensure-layer (name / doc)
  (if (not (tblsearch "LAYER" name))
    (progn
      (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
      (vla-add (vla-get-Layers doc) name)))
  name)

(defun cf:draw-table (rows p / i stn y row txt lay h sty)
  (setq lay (cf:ensure-layer "CUTFILL")
        sty (getvar "TEXTSTYLE")
        h   (* 3.5 (getvar "DIMSCALE") h)
        h   (if (<= h 0.0) 3.5 h)
        y   (- (cadr p) h)
        i   0)
  (foreach row rows
    (if (= i 0)
      (setq txt
        (strcat "STA    CHAINAGE     A.CUT    A.FILL     V.CUT      V.FILL     CUM.CUT    CUM.FILL"))
      (setq stn row
            txt
        (strcat
          (rtos (nth 0 stn) 2 0) "      "
          (rtos (nth 1 stn) 2 2) "    "
          (rtos (nth 2 stn) 2 2) "   "
          (rtos (nth 3 stn) 2 2) "    "
          (rtos (nth 4 stn) 2 2) "    "
          (rtos (nth 5 stn) 2 2) "    "
          (rtos (nth 6 stn) 2 2) "   "
          (rtos (nth 7 stn) 2 2))))
    (entmakex
      (list '(0 . "TEXT")
            (cons 8 lay)
            (cons 10 (list (- (car p) 30.0) y))
            (cons 40 h)
            (cons 1 txt)
            (cons 7 sty)
            (cons 72 0)
            (cons 11 (list (- (car p) 30.0) y))
            (cons 41 1.0)))
    (setq y (- y (* h 1.5))
          i (1+ i)))
  (princ))

(defun cf:report (result / rows totC totF p tot-row txt lay h sty)
  (setq rows (car result)
        totC (cadr result)
        totF (caddr result)
        p (getpoint "\n\nTitik untuk placing table hasil: ")
        lay (cf:ensure-layer "CUTFILL")
        sty (getvar "TEXTSTYLE")
        h   (* 4.0 (getvar "DIMSCALE") h)
        h   (if (<= h 0.0) 4.0 h))
  (cf:draw-table rows p)
  (setq txt
    (strcat "TOTAL VOL.CUT = " (cf:fmt totC) " m3    TOTAL VOL.FILL = " (cf:fmt totF) " m3"))
  (entmakex
    (list '(0 . "TEXT")
          (cons 8 lay)
          (cons 10 (list (- (car p) 30.0) (- (+ (cadr p) h) (* h 0.6))))
          (cons 40 h)
          (cons 1 txt)
          (cons 7 sty)
          (cons 72 0)


;;; ---------------------------------------------------------------------------
;;; Input interaktif
;;; ---------------------------------------------------------------------------
(defun c:CUTFILL
  (/ n i sc bL bR cf zL zC zR stations)
  (princ "\n=== HITUNGAN CUT & FILL (Average End Area) ===")
  (setq n  (cf:geti "Berapa banyak station" 5)
        sc (cf:getr "Side slope H:V" 2.0)
        bL (cf:getr "Lebar bahu kiri (m)" 3.0)
        bR (cf:getr "Lebar bahu kanan (m)" 3.0)
        stations nil
        i 1)
  (repeat n
    (setq stn (cf:getr (strcat "\nStation " (itoa i) " - CHAINAGE (m)") (* 20.0 (1- i)))
          zL  (cf:getr "  Elevasi terreno KIRI  (m)" 10.0)
          zC  (cf:getr "  Elevasi terreno TENGAH (m)" 10.0)
          zR  (cf:getr "  Elevasi terrain KANAN (m)" 10.0))
    (setq stations
      (cons (list (float i) stn zL zC zR bL bR) stations))
    (setq i (1+ i)))
  (cf:report (cf:compute (reverse stations) sc))
  (princ)
)

;;; ---------------------------------------------------------------------------
;;; Load dari file teks
;;; Format tiap baris: chain, elev-kiri, elev-tengah, elev-kanan
;;; Baris kosong dan baris ber-awal ';' diabaikan
;;; ---------------------------------------------------------------------------
(defun cf:load-file (path / f line parts data stations)
  (setq f (open path "r"))
  (if (null f)
    (progn
      (princ (strcat "\nGagal membuka file: " path))
      nil)
    (progn
      (while (setq line (read-line f))
        (setq line (vl-string-trim " \t" line))
        (if (and (> (strlen line) 0) (not (= (substr line 1 1) ";")))
          (progn
            (setq parts (cf:split line))
            (if (>= (length parts) 4)
              (setq data (cons (mapcar 'atof parts) data))))))
      (close f)
      (reverse data))))

(defun cf:split (s / i n c out)
  (setq i 1
        n (strlen s)
        out nil
        c nil)
  (while (<= i n)
    (setq ch (substr s i 1))
    (if (member ch '(" " "," "\t"))
      (progn
        (if c (progn (setq out (cons c out)) (setq c nil))))
      (setq c (strcat c ch)))
    (setq i (1+ i)))
  (if c (setq out (cons c out)))
  (reverse out))

(defun c:CUTFILLFILE
  (/ path data bL bR sc stations i)
  (princ "\n=== CUT & FILL dari FILE ===")
  (setq path (getfiled "Pilih file data cut & fill" "" "txt" 0)
        sc   (cf:getr "Side slope H:V" 2.0)
        bL   (cf:getr "Lebar bahu kiri (m)" 3.0)
        bR   (cf:getr "Lebar bahu kanan (m)" 3.0))
  (if path
    (progn
      (setq data (cf:load-file path))
      (if data
        (progn
          (setq i 0
                stations nil)
          (foreach row data
            (setq stations
              (cons (list (float (1+ i))
                          (nth 0 row)
                          (nth 1 row)
                          (nth 2 row)
                          (nth 3 row)
                          bL bR)
                    stations))


;;; ---------------------------------------------------------------------------
;;; Demo / uji coba
;;; ---------------------------------------------------------------------------
(defun c:CUTDEMO
  (/ path f)
  (setq path (strcat (getvar "DWGPREFIX") "cutfill_demo.txt"))
  (setq f (open path "w"))
  (write-line "; chain, elev-kiri, elev-tengah, elev-kanan" f)
  (write-line "0, 11.0, 10.0, 11.0" f)
  (write-line "20, 8.0, 7.0, 8.0" f)
  (write-line "40, 5.0, 4.0, 5.0" f)
  (write-line "60, 7.0, 6.0, 7.0" f)
  (write-line "80, 9.0, 8.0, 9.0" f)
  (write-line "100, 11.0, 10.0, 11.0" f)
  (close f)
  (princ (strcat "\nFile demo dibuat: " path))
  (princ "\nJalankan CUTFILLFILE untuk mengujinya.")
  (princ))

(princ "\ncutfill.lsp loaded. Commands: CUTFILL, CUTFILLFILE, CUTDEMO")
(princ)

            (setq i (1+ i)))
          (cf:report (cf:compute (reverse stations) sc)))
        (princ "\nTidak ada data valid di file."))
      (princ)))
  (princ))

          (cons 11 (list (- (car p) 30.0) (- (+ (cadr p) h) (* h 0.6))))
          (cons 41 1.0)))
  (princ "\n")
  (princ txt))

            vF 0.0))
    (setq row (list (nth 0 st)
                    (nth 1 st)
                    (nth 0 ar)
                    (nth 1 ar)
                    vC
                    vF
                    cumC
                    cumF))
    (setq res (cons row res))
    (setq prev (list (nth 0 ar) (nth 1 ar))))
  (list (reverse res) cumC cumF))
