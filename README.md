# Spectral-Regression-Modeling-for-Cadmium-Estimation-in-Leaf-Tissue-Using-PLSR-and-PCA
Hyperspectral Regression Modeling for Heavy Metal Estimation (PLSR vs PCR)
Overview

This project implements hyperspectral regression modeling techniques to estimate heavy metal concentration (Cadmium) in plant tissue using reflectance data.

The objective was to compare Partial Least Squares Regression (PLSR) and Principal Component Regression (PCR) for predicting metal concentration from high-dimensional spectral data.

Dataset

Hyperspectral reflectance measurements (500–998 nm)

Target variable: Cadmium concentration (Cd)

Vegetation indices computed:

NDVI

CIre

PSRI

HMSSI

Methodology
1. Spectral Preprocessing

Extraction of spectral bands

Removal of missing values

Outlier filtering (2σ threshold)

70/30 train-validation split

2. Partial Least Squares Regression (PLSR)

10-fold cross validation

Latent variable selection

RMSE analysis

R² evaluation

3. Principal Component Regression (PCR)

PCA decomposition

Component selection

Regression modeling

Model performance comparison

Results

PLSR explained a high percentage of variance in the response variable.

PLSR achieved lower RMSE compared to PCR.

Demonstrates the advantage of supervised dimensionality reduction in high-dimensional spectral modeling.

Technologies Used

MATLAB

Statistics Toolbox

Neural Network Toolbox (dividerand)

PCA / Regression functions
