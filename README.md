# milk-streamtelemetry-cca
Canonical Correlation Analysis and PCA tools for synchronized telemetry sets.

## Description

This suite of tools performs Canonical Correlation Analysis (CCA) and Principal Component Analysis (PCA) on series of images (telemetry streams).
The input typically consists of 3D FITS cubes (dimensions x, y, N), representing a series of N images.

The suite includes three programs:
*   `milk-streamtelemetry-cca`: Performs CCA between two datasets.
*   `milk-streamtelemetry-pca`: Performs PCA (SVD) on a single dataset.
*   `milk-streamtelemetry-recon`: Reconstructs datasets from modes and coefficients.

Dependencies: CFITSIO, OpenBLAS, LAPACKE.

## Compilation

Coded in C, using gcc and cmake for compilation.
```bash
mkdir build
cd build
cmake ..
make
```

## Usage

All programs support CFITSIO's extended filename syntax, allowing you to read subsets (crops) of images.
Example: `input.fits[1:50,1:50,1:1000]`.

### 1. Principal Component Analysis (PCA)

Performs SVD on the dataset to extract spatial modes and temporal coefficients.
Note: The data is **not** de-averaged (centered) before analysis. The first mode captures the average signal and is forced to have a positive average coefficient.

```bash
milk-streamtelemetry-pca <npca> <input.fits> <modes_output.fits> <coeffs_output.fits>
```
*   `<npca>`: Number of principal components to compute.
*   `<input.fits>`: Input 3D FITS cube (x, y, N).
*   `<modes_output.fits>`: Output 3D FITS file containing spatial modes (npca, y, x).
*   `<coeffs_output.fits>`: Output 2D FITS file containing coefficients (N, npca).

### 2. Canonical Correlation Analysis (CCA)

Performs CCA between two datasets (A and B). This program operates in two modes depending on the input:

#### Mode A: Raw Image Cubes (Direct or Internal PCA)
Takes two image cubes, performs CCA (optionally reducing dimension via internal PCA first), and outputs spatial canonical vectors.

```bash
milk-streamtelemetry-cca [-npca <n>] <nvec> <A.fits> <B.fits>
```
*   `-npca <n>`: (Optional) If specified, performs PCA on inputs first keeping `n` modes, then runs CCA on coefficients, and finally reconstructs spatial vectors.
*   `<nvec>`: Number of canonical vectors to compute.
*   `<A.fits>`, `<B.fits>`: Input 3D image cubes.
*   **Output**: `ccaA.fits` and `ccaB.fits` (3D cubes of spatial canonical vectors).

#### Mode B: Modular Workflow (CCA on Coefficients)
Takes two 2D coefficient matrices (produced by `milk-streamtelemetry-pca`), performs CCA, and outputs the resulting canonical weights as 2D matrices.

```bash
milk-streamtelemetry-cca <nvec> <coeffsA.fits> <coeffsB.fits>
```
*   `<coeffsA.fits>`, `<coeffsB.fits>`: Input 2D coefficient matrices (from PCA).
*   **Output**: `ccaA.fits` and `ccaB.fits` (2D matrices of canonical weights).
*   These outputs can be used with `milk-streamtelemetry-recon` to reconstruct the spatial maps.

### 3. Reconstruction

Reconstructs a dataset (or spatial maps) by multiplying a coefficient matrix with a mode matrix.

```bash
milk-streamtelemetry-recon <modes.fits> <coeffs.fits> <output.fits>
```
*   `<modes.fits>`: Spatial modes (e.g., from PCA output).
*   `<coeffs.fits>`: Coefficients (e.g., from PCA output or CCA Mode B output).
*   `<output.fits>`: Reconstructed 3D cube.

## Examples

### Standard CCA on full images
```bash
milk-streamtelemetry-cca 5 A.fits B.fits
```

### Modular Workflow (PCA -> CCA -> Recon)
This workflow is efficient for high-dimensional data.

1.  **Perform PCA on both streams:**
    ```bash
    milk-streamtelemetry-pca 100 A.fits modesA.fits coeffsA.fits
    milk-streamtelemetry-pca 100 B.fits modesB.fits coeffsB.fits
    ```

2.  **Perform CCA on the coefficients:**
    ```bash
    milk-streamtelemetry-cca 10 coeffsA.fits coeffsB.fits
    # Outputs ccaA.fits and ccaB.fits (2D weights)
    ```

3.  **Reconstruct Spatial Canonical Vectors:**
    ```bash
    milk-streamtelemetry-recon modesA.fits ccaA.fits cca_spatial_A.fits
    milk-streamtelemetry-recon modesB.fits ccaB.fits cca_spatial_B.fits
    ```
