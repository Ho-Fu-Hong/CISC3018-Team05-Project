import pandas as pd
import json
import os

# 1. Define file paths
# Assume yield_df.csv is located in the same directory as this script
CSV_FILE_PATH = 'yield_df.csv'

# Output path - Use raw string (r'') or double backslashes for Windows paths
# Option 1: Raw string (recommended)
OUTPUT_JSON_PATH = r'crop_dashboard\assets\data_all_records_new.json'

# Option 2: Double backslashes
# OUTPUT_JSON_PATH = 'crop_dashboard\\assets\\data_all_records_new.json'

# Option 3: Forward slashes (works on Windows too)
# OUTPUT_JSON_PATH = 'crop_dashboard/assets/data_all_records_new.json'

def convert_csv_to_json(csv_path, json_path):
    """
    Read CSV file and convert it to JSON format (list of records)
    """
    try:
        # Read CSV
        df = pd.read_csv(csv_path)

        # Rename columns to match the style of the previous JSON file (more concise)
        # This is optional but helps with frontend code consistency
        df.rename(columns={
            'average_rain_fall_mm_per_year': 'Rainfall',
            'pesticides_tonnes': 'Pesticides',
            'avg_temp': 'Avg_Temperature',
            'hg/ha_yield': 'Yield',
            'Area': 'Country',
            'Item': 'Crop'
        }, inplace=True)

        # Select main fields to display on the dashboard
        # Includes all original fields and normalized fields
        cols_to_keep = [
            'Country', 'Year', 'Crop', 'Yield', 
            'Rainfall', 'Pesticides', 'Avg_Temperature',
            'Yield_Normalized', 'Rainfall_Normalized', 'Temperature_Normalized','Country_Index','Crop_Index','Yield_Category',
            'Rainfall_Category','Temperature_Category',"ID"
        ]
        
        # Ensure all columns exist and select columns to output
        selected_df = df.reindex(columns=cols_to_keep, fill_value=None)
        
        # Convert DataFrame to JSON (orientation='records' outputs as JSON array of records)
        json_data = selected_df.to_json(orient='records', indent=4)
        
        # Save JSON file
        os.makedirs(os.path.dirname(json_path), exist_ok=True)
        with open(json_path, 'w', encoding='utf-8') as f:
            f.write(json_data)
        
        print(f"Successfully converted {len(df)} records to {json_path}")
        
    except FileNotFoundError:
        print(f"Error: Cannot find file {csv_path}. Please ensure the path is correct.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    # Assume this script is placed in the parent directory of crop_dashboard, and yield_df.csv is also there
    # If your file locations differ, please adjust CSV_FILE_PATH
    convert_csv_to_json(CSV_FILE_PATH, OUTPUT_JSON_PATH)