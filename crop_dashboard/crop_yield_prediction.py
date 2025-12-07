import os
import pandas as pd
import numpy as np
import pickle
import sys
import json
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_absolute_error, r2_score

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# --- Configuration ---
MODEL_PATH = os.path.join(BASE_DIR, 'best_model.pkl')
PREPROCESSOR_PATH = os.path.join(BASE_DIR, 'preprocessor.pkl')
CSV_PATH = os.path.join(BASE_DIR, 'yield_df.csv') # Used only for training/saving model

def load_and_preprocess_data(file_path):
    """Load and preprocess the data"""
    df = pd.read_csv(file_path)
    df.drop('Unnamed: 0', axis=1, inplace=True, errors='ignore')
    df.drop_duplicates(inplace=True)
    selected_cols = ['Year', 'Rainfall', 'Pesticides', 
                    'Avg_Temperature', 'Country', 'Crop', 'Yield']
    df = df[selected_cols]
    return df

def create_preprocessor():
    """Defines the column transformer for preprocessing features."""
    numerical_features = ['Year', 'Rainfall', 'Pesticides', 'Avg_Temperature'] 
    categorical_features = ['Country', 'Crop']
    
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numerical_features),
            ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features)
        ],
        remainder='passthrough'
    )
    return preprocessor

def prepare_features(df):
    """Separates features (X) and target (y)."""
    # Note: Column names must match the names used in load_model_and_predict
    X = df[['Year', 'Rainfall', 'Pesticides', 'Avg_Temperature', 'Country', 'Crop']]
    y = df['Yield']
    return X, y

def train_and_save_model():
    """Loads data, trains the best model (Decision Tree), and saves the model and preprocessor."""
    try:
        df = load_and_preprocess_data(CSV_PATH)
        X, y = prepare_features(df)
        
        # Split data for fitting the preprocessor
        X_train, _, y_train, _ = train_test_split(X, y, test_size=0.2, random_state=0)
        
        preprocessor = create_preprocessor()
        
        # Fit preprocessor on training data
        X_train_processed = preprocessor.fit_transform(X_train)
        
        # Train the model (Using Decision Tree as specified in original code snippet)
        best_model = DecisionTreeRegressor(random_state=0)
        best_model.fit(X_train_processed, y_train)

        # Save the model and preprocessor
        with open(MODEL_PATH, 'wb') as model_file:
            pickle.dump(best_model, model_file)
        with open(PREPROCESSOR_PATH, 'wb') as preprocessor_file:
            pickle.dump(preprocessor, preprocessor_file)
        
        print(f"Model and preprocessor saved successfully: {MODEL_PATH} and {PREPROCESSOR_PATH}")
        return True

    except Exception as e:
        print(f"Error during model training/saving: {e}", file=sys.stderr)
        return False

# --- NEW Prediction Function for PHP Integration ---

def load_model_and_predict(year, rainfall, pesticides, avg_temp, area, item):
    """
    Loads saved model and preprocessor to make a single prediction.
    """
    # The input columns MUST be in the exact order as they were passed to prepare_features
    
    try:
        # Load preprocessor and model
        preprocessor = pickle.load(open(PREPROCESSOR_PATH, 'rb'))
        model = pickle.load(open(MODEL_PATH, 'rb'))
        
        # Create input data DataFrame
        # IMPORTANT: Use original column names from CSV (average_rain_fall_mm_per_year, pesticides_tonnes, Area, Item)
        input_data = pd.DataFrame([{ 
            'Year': year, 
            'Rainfall': rainfall, 
            'Pesticides': pesticides, 
            'Avg_Temperature': avg_temp, 
            'Country': area, 
            'Crop': item 

        }])
        
        # Preprocess input data
        input_processed = preprocessor.transform(input_data)
        
        # Make prediction
        prediction = model.predict(input_processed)[0]
        
        # Return result formatted as JSON-ready dict
        return {"predicted_yield": round(float(prediction), 2)}

    except FileNotFoundError:
        return {"error": f"Model files ({MODEL_PATH} or {PREPROCESSOR_PATH}) not found. Please train and save the model first."}
    except Exception as e:
        return {"error": f"Prediction error: {str(e)}"}

# --- Main execution block for command-line (PHP call) ---

if __name__ == '__main__':
    # Check if this script is being run to TRAIN or PREDICT
    if len(sys.argv) == 2 and sys.argv[1] == 'train':
        # Used for initial setup: python crop_yield_prediction.py train
        train_and_save_model()
        sys.exit(0)

    # Prediction mode (called by PHP)
    # Expected arguments: year, rainfall, pesticides, temp, country, crop
    if len(sys.argv) == 7:
        try:
            year = int(sys.argv[1])
            rainfall = float(sys.argv[2])
            pesticides = float(sys.argv[3])
            avg_temp = float(sys.argv[4])
            area = sys.argv[5]
            item = sys.argv[6]
            
            result = load_model_and_predict(year, rainfall, pesticides, avg_temp, area, item)
            
            # Output JSON result
            print(json.dumps(result))

        except ValueError:
            print(json.dumps({"error": "Invalid input format. Ensure Year is int, and others are numeric."}), file=sys.stderr)
        except Exception as e:
            print(json.dumps({"error": f"An unexpected error occurred: {str(e)}"}), file=sys.stderr)
    else:
        # This message will be caught by PHP if execution fails due to wrong parameters
        print(json.dumps({"error": "Missing or incorrect number of input parameters (expected 6 for prediction, or 'train')."}), file=sys.stderr)


