set terminal pngcairo size 1000,1000 enhanced font "Arial,10"
set output "./pca_corner.png"

# Margins
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0

set multiplot layout 5,5 rowsfirst title "PCA Variables (Coeffs A vs B)" offset 0,-0.05

# Pre-calculate standard deviations
array stdA[5]
array stdB[5]
do for [k=1:5] {
    stats "./pca_vars.dat" u k nooutput
    stdA[k] = STATS_stddev
    stats "./pca_vars.dat" u (k+5) nooutput
    stdB[k] = STATS_stddev
}

do for [j=0:4] {
    do for [i=0:4] {
        colA = i + 1
        colB = j + 6

        # Calculate Correlation
        stats "./pca_vars.dat" u colA:colB nooutput
        corr = STATS_correlation

        # Reset labels
        unset label

        # Correlation Label (Top Right)
        set label 1 sprintf("r=%.2f", corr) at graph 0.95, 0.95 right font ",9"

        # Standard Deviation Labels
        # Top of Column
        if (j == 0) {
            set label 2 sprintf("σ(A%d)=%.2g", i, stdA[i+1]) at graph 0.5, 1.1 center font ",9"
        }
        # Right of Row
        if (i == 4) {
            set label 3 sprintf("σ(B%d)=%.2g", j, stdB[j+1]) at graph 1.1, 0.5 left font ",9"
        }

        # Axis Labels (Outer Only - optional, explicitly asked to remove values)
        # We unset values but keep structure
        set format x ""
        set format y ""
        unset xlabel
        unset ylabel

        if (j == 4) { set xlabel sprintf("A%d", i) }
        if (i == 0) { set ylabel sprintf("B%d", j) offset 1 }

        unset key
        set size square

        # Zero Cross
        set xzeroaxis lt 1 lc rgb "black"
        set yzeroaxis lt 1 lc rgb "black"

        plot "./pca_vars.dat" using colA:colB pt 7 ps 0.5 lc rgb "black"
    }
}
unset multiplot
