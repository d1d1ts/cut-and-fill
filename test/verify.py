"""Verifikasi matematika cutfill.lsp (port ke Python, logika identik).

Jalankan: python test/verify.py
"""


def nonneg(x):
    return x if x > 0 else 0.0


def trap_half(d1, d2, sc):
    if sc > 0:
        return (sc * (d1 + d2) * (d1 + d2)) / 4.0
    return 0.0


def station(zL, zC, zR, bL, bR, sc):
    dL = zL - zC
    dR = zR - zC
    cL = nonneg(dL)
    cR = nonneg(dR)
    fL = -dL if dL < 0 else 0.0
    fR = -dR if dR < 0 else 0.0
    return [
        trap_half(cL, 0.0, sc) + trap_half(0.0, cR, sc),
        trap_half(fL, 0.0, sc) + trap_half(0.0, fR, sc),
        bL * cL + bR * cR,
        bL * fL + bR * fR,
    ]


def vol(a1, a2, d):
    return ((a1 + a2) / 2.0) * d


DATA = [
    (0, 11.0, 10.0, 11.0),
    (20, 8.0, 7.0, 8.0),
    (40, 5.0, 4.0, 5.0),
    (60, 7.0, 6.0, 7.0),
    (80, 9.0, 8.0, 9.0),
    (100, 11.0, 10.0, 11.0),
]
SC = 2.0
B_L = 3.0
B_R = 3.0


def main():
    cum_c = 0.0
    cum_f = 0.0
    prev = None
    print("STA  CHAIN   A.CUT   A.FILL      V.CUT    V.FILL      CUM.CUT")
    for i, (ch, zL, zC, zR) in enumerate(DATA):
        ar = station(zL, zC, zR, B_L, B_R, SC)
        if prev:
            d = ch - prev[0]
            v_c = vol(prev[1], ar[0], d)
            v_f = vol(prev[2], ar[1], d)
            cum_c += v_c
            cum_f += v_f
        else:
            v_c = 0.0
            v_f = 0.0
        print(
            "%3d %7.1f %8.2f %8.2f %10.2f %10.2f %12.2f"
            % (i, ch, ar[0], ar[1], v_c, v_f, cum_c)
        )
        prev = (ch, ar[0], ar[1])
    print("")
    print("TOTAL CUT  = %.2f m3" % cum_c)
    print("TOTAL FILL = %.2f m3" % cum_f)
    print("")
    print("Cek manual station 0: sisi kiri d=1.0, slope 1:2")
    print("  tiap sisi: d * (2d/s) / 2 = 1.0 * 1.0 / 2 = 0.50 m2")
    print("  dua sisi  = 1.00 m2  (bandingkan dengan A.CUT station 0)")


if __name__ == "__main__":
    main()
