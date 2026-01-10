set terminal pngcairo size 1000,1000 enhanced font "Arial,10"
set output "./cca_corner.png"

# Define style for boxed labels
set style textbox opaque noborder
set style fill solid 1.0 noborder

# Use margins to leave space for outer labels, spacing 0,0 to touch plots
set multiplot layout 5,5 rowsfirst title "CCA Variables (A vs B)" margins 0.06, 0.94, 0.06, 0.92 spacing 0,0

# Pre-calculate standard deviations
array stdA[5]
array stdB[5]
do for [k=1:5] {
    stats "./cca_vars.dat" u k nooutput
    stdA[k] = STATS_stddev
    stats "./cca_vars.dat" u (k+5) nooutput
    stdB[k] = STATS_stddev
}

do for [j=0:4] {
    do for [i=0:4] {
        colA = i + 1
        colB = j + 6

        # Calculate Correlation
        stats "./cca_vars.dat" u colA:colB nooutput
        corr = STATS_correlation

        # Reset labels
        unset label

        # Correlation Label (Top Right): Bold Red, White Box
        set label 1 sprintf("r=%.2f", corr) at graph 0.90, 0.90 right font "Arial-Bold,10" textcolor rgb "red" front boxed

        # Standard Deviation Labels
        # Top of Column
        if (j == 0) {
            set label 2 sprintf("σ(A%d)=%.2g", i, stdA[i+1]) at graph 0.5, 1.05 center font "Arial,9"
        }
        # Right of Row
        if (i == 4) {
            set label 3 sprintf("σ(B%d)=%.2g", j, stdB[j+1]) at graph 1.05, 0.5 left font "Arial,9"
        }

        # Axis Labels (Outer Only)
        set format x ""
        set format y ""
        unset xlabel
        unset ylabel
        unset xtics
        unset ytics

        # Restore tics structure but no values (or remove ticks completely?)
        # User said "remove the values on the x and y axes ticks", imply ticks might remain?
        # But for corner plot usually inner ticks are removed.
        # Let's keep ticks but remove format as requested.
        set tics scale 0.5

        if (j == 4) { set xlabel sprintf("A%d", i) }
        if (i == 0) { set ylabel sprintf("B%d", j) offset 1 }

        unset key
        # Make plots square-ish? 'set size square' can mess with layout filling.
        # With spacing 0,0, layout determines size. 'set size ratio 1' might create gaps.
        # Let's rely on layout.

        # Zero Cross
        set xzeroaxis lt 1 lc rgb "black"
        set yzeroaxis lt 1 lc rgb "black"

        plot "./cca_vars.dat" using colA:colB pt 7 ps 0.5 lc rgb "black"
    }
}
unset multiplot
