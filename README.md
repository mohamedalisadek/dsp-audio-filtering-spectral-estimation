# DSP Audio Signal Processing: Spectral Estimation and Digital Filtering

## Overview

This project implements spectral estimation and FIR digital filter design to suppress narrowband sinusoidal interference from an audio signal. It was completed as part of the DSP (CIE 247) course at Zewail City of Science and Technology, Spring 2025.

The work is divided into two parts: Welch-based power spectral density estimation, and a quantitative multi-criteria filter selection and application pipeline.

---

## Objective

Given an audio signal sampled at 32 kHz, a sinusoidal tone at 15.2 kHz with amplitude 1.8 was injected as interference. The goal was to:

1. Analyze the spectral characteristics of the contaminated signal using Welch's method, and study the effect of each estimation parameter.
2. Design, compare, and select an FIR digital filter that suppresses the 15.2 kHz interference while preserving the audible content of the original signal.

---

## Results

- The interference at 15.2 kHz was successfully attenuated by over 100 dB using the selected filter.
- The passband from 0 to 14.7 kHz was preserved with a maximum ripple of 0.44 dB.
- PSD comparison before and after filtering confirmed complete suppression of the interference spike with no audible distortion to the original signal.
- The selected filter (FIR Least-Squares Lowpass, order 200) achieved the highest utility score of 0.825 in the decision matrix analysis.

---

## Methodology

### Part 1: Spectral Estimation

A 3-second segment was extracted from the center of the audio file. The interference tone was generated and added to the segment. Welch's method (`pwelch`) was then applied to estimate the single-sided power spectral density of the combined signal.

The following parameters were varied systematically to study their effect on the PSD estimate:

| Parameter | Values Tested |
|---|---|
| Window type | Rectangular, Hanning, Hamming, Blackman |
| FFT size (NFFT) | 256, 1024, 4096 |
| Window size | 128, 256, 512 |
| Overlap percentage | 0%, 25%, 50%, 75% |
| Sampling frequency passed to pwelch | 0.25Fs, 0.5Fs, Fs, 2Fs |

### Part 2: Filter Design and Selection

Three FIR filters were designed using MATLAB's Filter Designer toolbox and evaluated against four criteria:

| Criterion | Weight | Rationale |
|---|---|---|
| Stopband attenuation at 15.2 kHz | 0.45 | Primary objective |
| Maximum passband ripple | 0.25 | Audio fidelity |
| Filter order | 0.20 | Computational cost |
| Preserved bandwidth | 0.10 | Signal integrity |

**Proposed filters:**

- **Filter 1** — Equiripple Lowpass (FIRPM), order 170, Fpass = 14.8 kHz, Fstop = 15.2 kHz
- **Filter 2** — Least-Squares Lowpass (FIRLS), order 200, Fpass = 14.7 kHz, Fstop = 15.1 kHz
- **Filter 3** — Blackman-windowed Bandstop (FIR1), order 250, stopband 14.8–15.6 kHz

A normalized decision matrix was used to compute a weighted utility score for each filter. Filter 2 (Least-Squares LPF) was selected with a utility score of 0.825 due to its superior attenuation (100.65 dB) and low passband ripple (0.44 dB).

---

## Key Findings

**Spectral estimation:**

- Increasing NFFT improves frequency resolution but increases computation time; the interference spike at 15.2 kHz becomes sharply identifiable at NFFT = 4096.
- Larger window sizes improve frequency resolution at the cost of time localization and increased variance.
- The Blackman window provides the best sidelobe suppression; the rectangular window exhibits the highest spectral leakage.
- Higher overlap percentages reduce variance and smooth the PSD estimate; 50% overlap was used as the baseline.
- Passing an incorrect Fs value to `pwelch` scales the frequency axis without affecting the underlying computation, causing misidentification of spectral features.

**Filter design:**

- The Equiripple (FIRPM) filter achieves the lowest order for a given set of specifications but provides only 61 dB attenuation at the interference frequency.
- The Least-Squares (FIRLS) filter achieves 100.65 dB attenuation with the smallest passband ripple among the three candidates, at the cost of a slightly higher order (200).
- The Blackman-windowed bandstop filter has the highest order (250) and the largest passband ripple (5.96 dB), making it the weakest candidate despite preserving more total bandwidth.

---

## Repository Structure

```
.
├── Part1_spectral_analysis.m     # Welch PSD estimation and parameter study
├── Part2_filter_design.m         # Filter design, decision matrix, and filtering
├── filter1.m                     # Equiripple Lowpass filter (FIRPM)
├── filter2.m                     # Least-Squares Lowpass filter (FIRLS)
├── filter3.m                     # Blackman-windowed Bandstop filter (FIR1)
├── filter4.m                     # Blackman-windowed Bandpass filter (FIR1)
└── DSP_Project_202200594.pdf     # Full project report
```

---

## Requirements

- MATLAB R2024b or later
- DSP System Toolbox
- Signal Processing Toolbox
- Audio file: `music_test_fayrouz.mp3` (not included in repository)

---

## Author

Mohammed Ali Sadek — Student ID 202200594  
Communications and Information Engineering Program, Zewail City of Science and Technology
