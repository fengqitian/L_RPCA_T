# L-RPCA-T: Infrared Small Target Detection

This repository contains the official MATLAB implementation of the **L-RPCA-T** algorithm for infrared small target detection. 

The L-RPCA-T algorithm effectively suppresses complex background clutter and enhances small targets in infrared image sequences by combining patch-based Local Weighted Robust Principal Component Analysis (RPCA) with spatio-temporal filtering.

## 📁 Directory Structure

Ensure your project directory is organized as follows before running the code:

```text
├── 1/                        # Sample dataset folder
│   ├── images/               # Input infrared image sequence (*.bmp, *.png, *.jpg, etc.)
│   └── masks/                # Ground truth masks (if applicable/for evaluation)
├── binary_results/           # Output directory for the generated binary maps (auto-generated)
├── L_RPCA_T_Solver_v5.m      # Core algorithm function
├── run_demo_binary.m         # Demo script to execute the algorithm
└── README.md                 # This documentation
⚙️ Prerequisites
MATLAB (Tested on recent versions, e.g., R2020a or later).

Image Processing Toolbox (required for functions like imtophat, fspecial, imfilter).

Parallel Computing Toolbox (recommended, as the code utilizes parfor for patch processing acceleration).
🚀 How to Use
Clone the repository:

Bash
git clone [https://github.com/YourUsername/L-RPCA-T.git](https://github.com/YourUsername/L-RPCA-T.git)
cd L-RPCA-T
Prepare your data:
Place your sequence of infrared images inside the 1/images/ directory. The demo script supports common image formats (e.g., .bmp, .png, .jpg, .tif).

Run the demo:
Open MATLAB, navigate to the project directory, and execute the demo script:

Matlab
run_demo_binary
Check the results:

The script will process the image sequence frame by frame.

A figure window will pop up comparing the original input frame with the final binary detection result for the middle frame.

The complete set of binary detection maps will be automatically saved in the binary_results/ directory.

🧠 Algorithm Pipeline Overview
Local Prior Weighting: Calculates a spatial weight map based on the structure tensor (corner detection) to penalize background edges and preserve target sparsity.

Patch-based Weighted RPCA: Divides the image into overlapping patches and applies the Weighted RPCA solver to separate the sparse target matrix from the low-rank background matrix.

Spatio-Temporal Energy Filtering: Stacks the sparse maps and applies 3D (spatial + temporal) smoothing to suppress isolated noise and enhance temporal consistency.

Adaptive Thresholding: Uses a statistical threshold (mean + 3 * std) combined with 3D connected component analysis to output the final accurate binary mask.
