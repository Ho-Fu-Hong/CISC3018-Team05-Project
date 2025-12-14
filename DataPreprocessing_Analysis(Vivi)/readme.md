# Agricultural Data Analysis Project

## Overview
This project analyzes agricultural data from multiple sources to predict crop yields using machine learning models. It consists of two main components:
1. **Data Preprocessing Pipeline** - Cleans and integrates agricultural datasets
2. **Crop Yield Prediction** - Applies machine learning models to predict yields

## Notebook 1: Agricultural Data Preprocessing Pipeline

### Purpose
Processes and integrates four agricultural datasets for analysis:
- Rainfall data
- Pesticides data
- Yield data
- Temperature data

### Key Steps
1. **Data Loading**: Loads 4 CSV files using PySpark
2. **Data Cleaning**: Removes null values, standardizes column names, converts data types
3. **Country Standardization**: Maps 212 unique country names to consistent format
4. **Dataset Integration**: Uses INNER JOIN to combine all datasets
5. **Data Transformation**: Normalization, encoding, discretization
6. **Feature Analysis**: Identifies Crop_Index as strongest predictor (correlation: 0.327)
7. **Export**: Saves cleaned dataset (45,706 records, 21 features)

### Output
- Cleaned dataset: `yield_df.csv`
- 45,706 records with complete data
- 116 countries, 10 crops, years 1990-2013

## Notebook 2: Crop Yield Prediction Analysis

### Purpose
Predicts crop yields using various machine learning models.

### Models Implemented
1. **Linear Regression Models**:
   - Linear Regression (baseline)
   - Ridge Regression (L2 regularization)
   - Lasso Regression (L1 regularization)
   - Elastic Net (combined regularization)

2. **Advanced Models**:
   - K-Nearest Neighbors (KNN) - Best performer
   - Decision Tree
   - Random Forest
   - Gradient Boosting

### Key Results
- **Best Model**: KNN with k=3
  - R² Score: 0.9682 (96.8% variance explained)
  - MAE: 4,150.71 hg/ha
  - RMSE: 12,555.67 hg/ha
- **Dataset**: 45,706 records across 116 countries and 10 crops
- **Time Period**: 23 years of data

### Insights
1. Crop type (Item) is the strongest predictor of yield
2. Environmental factors show weak correlations with yield
3. KNN model demonstrates exceptional predictive power for agricultural data
4. Model is suitable for precision agriculture applications

## Requirements
- Python 3.x
- PySpark
- scikit-learn (for KNN implementation)
- Jupyter Notebook

## Files
- `agricultural_data_preprocessing.ipynb` - Data cleaning and integration
- `crop_yield_prediction_analysis.ipynb` - Machine learning analysis
- `yield_df.csv` - Processed dataset (output)

## How to Run
1. Ensure all data files are in the correct directory
2. Run the preprocessing notebook first to generate `yield_df.csv`
3. Run the prediction notebook to analyze the data and generate results

## Notes
- The project uses INNER JOINs to ensure data quality (no null values)
- Country names are standardized across all datasets
- All models are evaluated using R², MAE, and RMSE metrics
- Results show KNN is the best model for this agricultural prediction task
