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
