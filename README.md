# CEDAR (Efficient Content-adaptive Downward Robust Algorithm) - MATLAB Implementation

[![DOI](https://img.shields.io/badge/DOI-10.1007%2Fs11042--025--21136--y-blue)](https://doi.org/10.1007/s11042-025-21136-y) [![Cite](https://img.shields.io/badge/Cite-Paper-blue)](#citation) [![Google Scholar](https://img.shields.io/badge/Google_Scholar-Profile-4285F4?logo=googlescholar&logoColor=white)](https://scholar.google.com/citations?user=vvfARToAAAAJ) [![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-blue.svg?logo=mathworks&logoColor=white)](https://www.mathworks.com/products/matlab.html)

This repository contains the official MATLAB implementation of the **CEDAR** steganography scheme for JPEG images, as presented in:

> **Downward recompression robust JPEG steganography via efficient content-adaptive embedding**  
> *(Multimedia Tools and Applications, 2025)*

---

## Prerequisites

To run this code, ensure your environment meets the following requirements:
* **MATLAB** (R2020a or newer is recommended)
* A Windows 64-bit platform (for the Phil Sallee JPEG Toolbox `.mexw64` binaries)

---

## Repository Structure

To keep the repository clean and portable, the root folder contains only the main execution scripts and documentation, while the core algorithms and helpers are isolated in the `src/` directory:

```
/cedar_matlab/
  ├── CEDAR_Demo.m                # Main batch demo runner (configured with relative paths)
  ├── README.md                   # This documentation file
  ├── cover_images/               # 10 sample cover JPEGs (1.jpg to 10.jpg)
  └── src/                        # Core implementation and dependencies
        ├── CEDAR_Embed.m                 # Core embedding routine (LSB parity modification)
        ├── CEDAR_Extract.m               # Core LSB message extraction routine
        ├── CEDAR_GetRobustLoc.m          # Robust cover elements selection index mapping
        ├── CEDAR_RobustCoverElements.m   # Identifies robust coefficient lattices (RoLoS)
        ├── CEDAR_RobustMsgEmb.m          # Embeds a bit using parity rules (EmbedOne / EmbedZero)
        ├── CEDAR_EmbedOne.m              # Modifies DCT coefficient to yield odd parity
        ├── CEDAR_EmbedZero.m             # Modifies DCT coefficient to yield even parity
        ├── CEDAR_nnzAC.m                 # Count non-zero AC coefficients
        ├── CEDAR_CalcMsgLen.m            # Computes length of secret message vector
        ├── CEDAR_GenQuantTable.m         # Standard JPEG quantization table generator
        ├── SecretMsg.mat                 # Sample secret message data
        └── *.mexw64                      # Phil Sallee's JPEG Toolbox MEX binaries
```

---

## Running the Demo

Open MATLAB, navigate to `/cedar_matlab/`, and execute:
```matlab
run('CEDAR_Demo.m')
```
The script will run batch processing over the 10 cover images in the dataset and output a results summary including capacity, PSNR, SSIM, and BER (Bit Error Rate) metrics. To test the strict paper domain constraint instead, toggle the `RestrictToDomainE` variable in `CEDAR_Demo.m` to `true`.

---

## Citation

If you use this code or dataset in your research, please cite the published paper:

**DOI:** [10.1007/s11042-025-21136-y](https://doi.org/10.1007/s11042-025-21136-y)

**BibTeX:**
```bibtex
@article{kumar2025downward,
  title={Downward recompression robust JPEG steganography via efficient content-adaptive embedding},
  author={Kumar, Rakesh and Bansal, Savina and Bansal, R. K.},
  journal={Multimedia Tools and Applications},
  year={2025},
  publisher={Springer},
  doi={10.1007/s11042-025-21136-y}
}
```

**APA Citation:**
Kumar, R., Bansal, S., & Bansal, R. K. (2025). Downward recompression robust JPEG steganography via efficient content-adaptive embedding. *Multimedia Tools and Applications*. https://doi.org/10.1007/s11042-025-21136-y
